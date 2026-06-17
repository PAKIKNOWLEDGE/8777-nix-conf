# Reasonix project memory

Notes the user pinned via the `#` prompt prefix. The whole file is
loaded into the immutable system prefix every session — keep it terse.

- NixOS 配置项目状态

## 机器
- X250（当前）/ T430（待迁移）
- NixOS 26.05, x86_64
- SDDM 登录管理器, i3 + XFCE 可切换

## 目录结构 (`~/nix/nixos/`)
- `configuration.nix` — 系统配置（包含用户包）
- `hardware-configuration.nix` — 自动生成
- `dotfiles/` — 所有配置文件（原始格式），手动部署到 ~/.config/
- `debian-archive/` — Debian 时期备份，被 .gitignore 忽略

## 关键决策
- **Home Manager 已移除** — dotfiles 不再经过 Nix store，避免只读问题
- 用户级软件放在 `users.users.pakiknowledge.packages` 里（不走 HM）
- `systemPackages` 只放大件系统工具
- 配置改完后需要手动 `cp -r ~/nix/nixos/dotfiles/* ~/.config/`

## 下次要做的
1. `sudo nixos-rebuild switch`
2. `cp -r ~/nix/nixos/dotfiles/* ~/.config/`
3. 为 T430 迁移做准备给你之前的上下文
