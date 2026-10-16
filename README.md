# ~/nix/nixos

三台真机的 NixOS flake 配置 + 一套 dotfiles 同步系统。

![](./nix-b-e.png)

远程仓库：`https://github.com/PAKIKNOWLEDGE/8777-nix-conf.git`（分支 `master`）。
动手前请先读 [AGENTS.md](AGENTS.md)——它是本仓库对人和 coding agent 共同的硬规则（活系统、
验证只用无副作用命令、`hardware.nix` 不跨机复制、中文注释是风格等）。

---

## 先看懂：两层配置

同一个仓库里并存**两套互不知晓**的配置体系。搞清一件事归哪层，比记命令重要。

| | NixOS 系统层 | dotfiles 配置层 |
|---|---|---|
| 管什么 | 软件包、服务、内核、驱动、用户 | `~/.config` 下约 25 个应用的配置 |
| 声明方式 | 声明式（nix） | 命令式（`sync.sh` + rsync） |
| 入口 | `flake.nix` → `configuration.nix` + `hosts/<Host>/` | `dotfiles/sync.sh` |
| 生效 | `nixos-rebuild switch --flake .#<Host>` | `dotfiles/sync.sh deploy` |
| 机器目录 | `hosts/<Host>/`（代号习惯大写） | `dotfiles/hosts/<host>/`（代号习惯小写） |

声明式这一轨内部再分两层（AGENTS.md 说的"双轨"是指 NixOS/HM 轨 vs sync.sh 轨）：
**系统层** `configuration.nix` + `hosts/<Host>/` 管全机，**用户层** `home.nix`（home-manager）管当前用户——
把 krita / libreoffice / gimp 这类巨无霸从系统层挪出来，让系统构建不必等它们；git、bash 的配置也在这层。

两套 `hosts/` 的代号大小写不一致是历史事实，靠 `dotfiles/sync.sh` 顶部的 `HOST_ALIASES` 桥接。
**一个应用只归一层**：新配置默认先进 `dotfiles/common/<app>/`，除非它是 `programs.*` 模块已有的。

## 机器

| flake 条目 | hostname | dotfiles 代号 | 角色 | 单机差异 |
|---|---|---|---|---|
| `ThinkPadX250` | `K1llingMyL0v3` | `thinkpadx250` | 日常笔记本 | `tlp`；双电池 BAT0/BAT1 的 i3status-rust 配置 |
| `pain` | `pain` | `pain` | 台式 | `zed-editor`；60 块 VGA 显示器的 EDID 注入（1366x768 modeline） |
| `T430` | `Gater` | `t430` | 退休搁置（配置保留，勿删） | `cloudflared`、合盖不休眠仍在；待办见 [docs/robustness.md](docs/robustness.md) |

每台机器的 `hosts/<Host>/hardware.nix` 由该机自己 `nixos-generate-config` 生成，三台内容互不兼容，
**不要跨机复制**。

## 仓库结构

```
flake.nix              入口：3 个 nixosConfiguration + 1 个 homeConfiguration
configuration.nix      NixOS 公共层（不要写单机差异）
home.nix               home-manager 用户层（大体积 GUI 包在这）
hosts/<Host>/          单机层：default.nix(差异) + hardware.nix(机器专属)
dotfiles/
  ├── sync.sh          配置层唯一入口：deploy / sync / diff / list / init-host / fish-links
  ├── common/<app>/    所有机器共用的基线
  └── hosts/<host>/    单台机器的覆盖层（整体替换 common 同名应用）
docs/                  运维手册 + 静态文档站（docs/pages/）
setup-mirrors.sh       新机首次把国内镜像写进 /etc/nix/nix.conf
AGENTS.md              仓库工作约定（人和 agent 都读这个）
```

## 日常命令

```bash
cd ~/nix/nixos

# 系统层：改完 nix 文件后
nix flake check                                  # 先验证
sudo nixos-rebuild switch --flake .#ThinkPadX250 # .#<条目名> 换机器

# 用户层
home-manager switch --flake .#pakiknowledge

# 配置层
dotfiles/sync.sh diff      # 只读预览差异（与 deploy 同一判据）
dotfiles/sync.sh deploy    # 仓库 → ~/.config（先预览再确认，旧文件自动备份）
dotfiles/sync.sh sync      # ~/.config → 仓库回写，按归属规则落位，之后记得 commit
```

本仓库是 flake，**不依赖 `/etc/nixos`**，克隆到任意位置都能构建；`/etc/nixos` 里残留的是新机默认死文件。
回滚到 channel 模式也很干净，见 [docs/new-pc-guide.md](docs/new-pc-guide.md) 第 6 节。

## 新机器 / 装机

- **接入一台新机器**：照 [docs/new-pc-guide.md](docs/new-pc-guide.md) 走，三步必须同步——
  `hosts/<Name>/`（含 `hardware.nix`）、`flake.nix` 注册 `nixosConfigurations.<Name>`、
  `dotfiles/sync.sh init-host <小写名>`。
- **首次装机（国内网络）**：先 `sudo ./setup-mirrors.sh` 把镜像写进 `/etc/nix/nix.conf`，或装机时直接指定：

  ```bash
  sudo nixos-install --flake ~/nix/nixos#<Host> \
    --option substituters "https://mirror.sjtu.edu.cn/nix-channels/store https://mirrors.nju.edu.cn/nix-channels/store https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org/"
  ```

## Flake inputs 与那个 25.11 pin

| input | 渠道 | 用途 |
|---|---|---|
| `nixpkgs` | `nixos-26.05` | 系统层与 HM 的主渠道 |
| `nixpkgs-25-11` | `nixos-25.11` | 只喂 `home.nix` 里的 krita |
| `home-manager` | `release-26.05`（`nixpkgs` follows 主渠道） | 用户层 |

`nixpkgs-25-11` 是为绕开 26.05 上 krita 6.0.1 的字体菜单 bug 留的 workaround，
**不是遗留垃圾，别顺手"清理"**。

## 公共层里值得知道的决策

`configuration.nix` 顶部有大段 rationale 注释，是历史决策记录。摘要：

- **引导**：systemd-boot（UEFI），`configurationLimit = 5` 防引导菜单堆积。
- **图形栈**：`ly` 做显示管理器 + XFCE + i3；`xkb.layout = "cn"`；打印服务关闭。
- **音频**：PipeWire（含 ALSA/32 位/pulse 兼容），PulseAudio 关闭。
- **输入法**：走 `i18n.inputMethod`（fcitx5 + gtk/qt 插件 + configtool），**不要**塞进 `systemPackages`；
  配套 `environment.sessionVariables` 显式声明 `GTK_IM_MODULE` 等，否则部分应用继承不到。
- **nix-ld**：为假设 FHS 路径（`/lib`、`/usr/lib`）的二进制提供兼容层，`libraries` 里带
  `tree-sitter`/`stdenv.cc.cc.lib`/`glib`/`zlib`——当初是给 tree-sitter 类插件续命的，
  `ld` 与 `packages` 必须共存。
- **字体**：`sarasa-gothic` + `nerd-fonts.jetbrains-mono`，注册进 fontconfig 才找得到。
- **用户与 shell**：单用户 `pakiknowledge`（`wheel` + `networkmanager`），`shell = pkgs.fish`；
  `programs.dconf` 开启，否则 GTK 主题 `settings.ini` 读不到。
- **构建体验**：`allowUnfree = true`；`nix-command` + `flakes` 实验特性开启；
  `trusted-users = root pakiknowledge`；自动 GC 每周清 7 天前的 generation。
- **镜像优先级**：SJTU > NJU > TUNA > USTC > cache.nixos.org（`flake.nix` 的 `extra-substituters`
  与 `configuration.nix` 的 `nix.settings.substituters` 两处都配了）。
- **已知问题**：T430 已退休搁置，防火墙、隧道未进服务、X250 的 tlp、GC 窗口等记在
  [docs/robustness.md](docs/robustness.md)，未授权不要改。`home.nix` 的
  `programs.bash.initExtra`（starship）对 fish 用户是死配置。

## dotfiles 同步系统要点

完整参考在 [docs/dotfiles-guide.md](docs/dotfiles-guide.md)。三条最容易踩的：

1. **别直接往 `~/.config` 写托管应用的配置**再指望 `git diff` 看得懂——用 `sync.sh sync` 回写，
   它会按"host 层存在则归 host，否则归 common"的规则落位。
2. **差异判据是内容比较（rsync `-c`）**，预览与真实部署同一判据、同一模式清单，所以 `diff` 看到什么就是什么。
3. **`SYNC_PATTERNS` 只有一份**（脚本顶部），展开成 `- pattern`（不传输）与 `P pattern`（本机文件免于
   `--delete`）两条规则。**不要改回 `--exclude`**：那会让本地产物逃出 rsync 视野，`--delete`
   随即把它们当"仓库里没有的东西"删掉（曾差点删掉本机 `fish/fish_variables`）。

## 文档

| 文档 | 内容 |
|---|---|
| [docs/README.md](docs/README.md) | 文档索引 + 两层快速对照 |
| [docs/new-pc-guide.md](docs/new-pc-guide.md) | 新机器接入：系统层 → 配置层端到端 |
| [docs/dotfiles-guide.md](docs/dotfiles-guide.md) | dotfiles 同步系统完整参考（命令、分层规则、安全机制、排障） |
| [docs/ref-notes.md](docs/ref-notes.md) | 借鉴 hakula139/nixos-config 的待落地项（CI、集中清单、nh、模块化） |
| [docs/DESIGN_NOTES.md](docs/DESIGN_NOTES.md) | 文档站的设计 token 与验证记录 |
| [docs/grok-build-config.md](docs/grok-build-config.md) · [docs/hermes-agent.md](docs/hermes-agent.md) · [docs/npm.md](docs/npm.md) | 零散备忘 |

静态站版本（手写转写，内容与 md 对应）：打开 [docs/pages/index.html](docs/pages/index.html)，
`file://` 直接可看；`style.css` 顶部那条 Google Fonts `@import` 拉不到时会自动回退本地字体。

## 环境事实

- 用户 `pakiknowledge`，uid 与 flake 中硬编码的用户名一致——**改用户名是破坏性变更**。
- 网络在中国大陆：nix / uv / cargo / npm 拉取一律优先国内镜像（清单见上节与 `setup-mirrors.sh`）。
- 本机 hostname `K1llingMyL0v3` = ThinkPadX250。
- 落到机器的动作（`nixos-rebuild` / `home-manager switch` / `sync.sh deploy`）由人类执行；
  agent 只做编辑与无副作用验证。
