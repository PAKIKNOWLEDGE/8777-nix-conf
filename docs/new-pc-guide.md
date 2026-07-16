# 新 PC 迁移指南

## 前置

以下操作前，先确保新机器已装好 NixOS（默认配置能开机就行）。

```bash
# 1. 备份默认配置
sudo mv /etc/nixos /etc/nixos.bak

# 2. 克隆仓库
git clone <你的仓库URL> ~/nix/nixos

# 3. 软链，让系统能找到
sudo ln -s ~/nix/nixos /etc/nixos
```

## 生成硬件配置

```bash
# 生成到 NewPC 目录下
sudo nixos-generate-config --dir /etc/nixos/hosts/NewPC

# 重命名为 hardware.nix
sudo mv /etc/nixos/hosts/NewPC/hardware-configuration.nix /etc/nixos/hosts/NewPC/hardware.nix

# 改为你的用户所有，方便编辑
sudo chown -R $USER:users /etc/nixos/hosts/NewPC/hardware.nix
```

## 编写差异配置

编辑 `hosts/NewPC/default.nix`：

```nix
{ ... }: {
  networking.hostName = "你的主机名";
  imports = [ ./hardware.nix ];

  # 跟 X250 不同的配置放这里
  # 台式没有触摸板 → services.libinput.enable = false
  # 想换 Hyprland → programs.hyprland.enable = true
  # 不需要 i3 → services.xserver.windowManager.i3.enable = false
}
```

## 更新 flake.nix

编辑 `flake.nix`，`NewPC` 条目应该已存在且未注释，确认一下即可。

如果需要改机器代号（比如不叫 `NewPC`），同步改 flake.nix 里的 attribute 名和 `hosts/` 下的目录名。

## 构建

```bash
cd /etc/nixos
git add .

# 验证配置
nix flake check

# 构建
sudo nixos-rebuild switch --flake /etc/nixos#NewPC
```

> 如果改过机器代号，`#NewPC` 换成你的代号。

## 收尾

```bash
# 同步 dotfiles
/etc/nixos/sync.sh --deploy

# 构建 home-manager
home-manager switch
```

## 回滚

不想用 flake 了？

```bash
sudo mv /etc/nixos /etc/nixos.flake-backup
sudo mv /etc/nixos.bak /etc/nixos
sudo nixos-rebuild switch
```

回到 channel 模式，旧配置完整保留。
