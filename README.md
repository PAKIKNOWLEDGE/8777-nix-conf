# NixOS Flake Configuration

Multi-machine NixOS configuration managed via Flake. Two layers: **system layer** (NixOS packages & services) and **config layer** (dotfiles sync).

## Machines

| Name | Role | Hostname | Notes |
|---|---|---|---|
| **pain** | Desktop | `pain` | VGA EDID override, Zed editor |
| **ThinkPadX250** | Laptop | `K1llingMyL0v3` | Lid close → suspend, TLP |
| **T430** | Gateway (Hermes) | `Gater` | Lid close → ignore |

## Structure

```
flake.nix              Flake entry — registers all machines
configuration.nix      Shared system config (public layer)
home.nix               Home Manager — user-level packages
hosts/<machine>/       Per-machine overrides + hardware.nix
dotfiles/
  common/              Configs shared across all machines
  hosts/<machine>/     Per-machine config overrides
  sync.sh              rsync-based deploy/sync script
docs/                  Operational docs (new PC guide, dotfiles reference, etc.)
```

### Flake Inputs

- **nixpkgs** `nixos-26.05`
- **nixpkgs-25-11** (pinned, used for krita — 26.05 version has font menu bug)
- **home-manager** `release-26.05`

## Quick Start

### Build system

```bash
cd ~/nix/nixos
sudo nixos-rebuild switch --flake .#<machine>
```

### Build user layer (Home Manager)

```bash
home-manager switch --flake ~/nix/nixos#pakiknowledge
```

### Fresh install with Chinese mirrors

```bash
sudo nixos-install --flake ~/nix/nixos#<machine> \
  --option substituters "https://mirror.sjtu.edu.cn/nix-channels/store https://mirrors.nju.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/"
```

## Add a New Machine

See [docs/new-pc-guide.md](docs/new-pc-guide.md) for full walkthrough.

TL;DR — three things to touch, all three must stay in sync:

1. `hosts/<Name>/default.nix` + `hardware.nix` — per-machine NixOS config
2. `flake.nix` — register in `nixosConfigurations`
3. `dotfiles/hosts/<name>/` — create placeholder (`sync.sh init-host <name>`)

## Dotfiles Sync

The `dotfiles/sync.sh` script handles two-way sync between the repo and `~/.config/`.

| Command | Direction | Description |
|---|---|---|
| `sync.sh deploy` | Repo → Local | Deploy common + host configs (dry-run first) |
| `sync.sh sync` | Local → Repo | Write back local changes to repo |
| `sync.sh diff` | — | Preview differences, no writes |
| `sync.sh list` | — | List managed apps and local status |

Host detection is automatic by hostname. If hostname differs from directory name, register an alias in the `HOST_ALIASES` array at the top of `sync.sh`.

## Key Design Decisions

- **Flake, not channels** — no `/etc/nixos` dependency. Clone anywhere, build with `.#<machine>`.
- **System vs Home Manager split** — heavy GUI apps (krita, libreoffice, gimp) live in `home.nix` to speed up system builds.
- **Mirror priority** — SJTU > NJU > TUNA > USTC > cache.nixos.org.
- **Auto GC** — weekly cleanup of generations older than 7 days.
- **nix-ld** — enabled for tree-sitter and Neovim plugin compatibility.
- **fcitx5** — Chinese input method, configured via NixOS module (not systemPackages).

## Mirrors

Configured in both `flake.nix` (extra-substituters) and `configuration.nix` (nix.settings.substituters):

1. SJTU — `mirror.sjtu.edu.cn`
2. NJU — `mirrors.nju.edu.cn`
3. TUNA — `mirrors.tuna.tsinghua.edu.cn`
4. USTC — `mirrors.ustc.edu.cn`

## Docs

- [New PC Guide](docs/new-pc-guide.md) — onboarding a new machine
- [Dotfiles Guide](docs/dotfiles-guide.md) — sync script reference
- [Design Notes](docs/DESIGN_NOTES.md) — docs site design tokens & rationale
- [Plugins](docs/PLUGINS.md) — DSH plugin list

## Remote

```
origin  https://github.com/PAKIKNOWLEDGE/8777-nix-conf.git
```
