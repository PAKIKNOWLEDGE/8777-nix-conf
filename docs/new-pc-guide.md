# 新机器接入指南

来一台新机器，两条线都要接：**系统层**（NixOS：装软件/服务）和**配置层**（dotfiles：装应用配置）。
顺序是先系统后配置。全程几条命令，照抄就行。

> **本仓库是 flake，不需要配置放在 `/etc/nixos`。** 仓库克隆到任意位置都能构建，
> 惯例放 `~/nix/nixos`。`/etc/nixos` 是 channel 时代的旧位置，本流程完全不碰它。

## 0. 总览

| 阶段 | 做什么 | 产物 |
|---|---|---|
| 前置 | 克隆仓库 | 仓库可用 |
| 系统层 | 硬件扫描、差异配置、flake 条目、构建 | 机器能开机进系统 |
| 配置层 | 留占位符、部署 dotfiles | 应用配置就位 |
| 收尾 | 验证 | 全部正常 |

> 约定：**任何新机器，无论有没有专属配置，都必须留占位符**。
> NixOS 侧 = `hosts/<Host>/` 目录；dotfiles 侧 = `sync.sh init-host` 建的 `.gitkeep`。
> 这样两套 `hosts/` 一眼就能看出全部被管理的机器。

## 1. 前置

```bash
git clone <你的仓库URL> ~/nix/nixos
```

## 2. 系统层（NixOS）

### 2.1 生成硬件配置

```bash
# 生成到仓库里的新机器目录
sudo nixos-generate-config --dir ~/nix/nixos/hosts/NewPC

# 重命名为 hardware.nix
sudo mv ~/nix/nixos/hosts/NewPC/hardware-configuration.nix ~/nix/nixos/hosts/NewPC/hardware.nix

# 改为用户所有，方便编辑
sudo chown -R $USER:users ~/nix/nixos/hosts/NewPC/hardware.nix
```

> `nixos-generate-config` 还会生成一个默认 `configuration.nix`，本仓库不用它，忽略即可。

### 2.2 写差异配置

编辑 `hosts/NewPC/default.nix`：

```nix
{ ... }: {
  networking.hostName = "你的主机名";
  imports = [ ./hardware.nix ];

  # 跟公共配置不同的放这里
  # 例: 台式没有触摸板 → services.libinput.enable = false
  # 例: 想换窗口管理器 → programs.niri.enable = true
}
```

> `configuration.nix` 是公共层，别动；机器差异都放 `hosts/<Host>/`。

### 2.3 注册到 flake

编辑 `flake.nix`，在 `nixosConfigurations` 里加一条（照抄现有的 ThinkPadX250 / pain 写法）：

```nix
NewPC = nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ./hosts/NewPC
  ];
};
```

> `NewPC` 这名字在 flake 条目、目录名、`#NewPC` 三处保持一致，别只改一半。

### 2.4 构建

```bash
cd ~/nix/nixos
git add .
nix flake check                 # 先验证，别直接 build
sudo nixos-rebuild switch --flake .#NewPC
```

> `.#NewPC` 的 `.` 就是当前目录（flake 仓库），等价于 `--flake ~/nix/nixos#NewPC`。

## 3. 配置层（dotfiles）

### 3.1 留占位符（必须，无论有无专属配置）

```bash
~/nix/nixos/dotfiles/sync.sh init-host NewPC
```

脚本会创建 `dotfiles/hosts/newpc/.gitkeep`（代号自动转小写）。
意义：`dotfiles/hosts/` 一眼看到全部被管理的机器，也提醒你这台机器"已纳入配置管理"。

### 3.2 部署公共配置

```bash
~/nix/nixos/dotfiles/sync.sh deploy
```

脚本自动按 `hostname` 识别主机。识别不到就加 `--host newpc`。
第一次部署会先预览差异 → 确认 → 写入（旧文件自动备份到 `~/.config/.dotfiles-backup/`）。

### 3.3 加专属配置（如果这台有）

有专属配置，就把目录放进占位符所在目录：

```bash
mkdir -p ~/nix/nixos/dotfiles/hosts/newpc/i3status-rust   # 示例
```

**判断放哪层的原则**（详见 [dotfiles-guide.md](dotfiles-guide.md)）：
- 所有机器都一样 → `dotfiles/common/`
- 只有这台不同 → `dotfiles/hosts/<代号>/`
- **别把"其实按机器分"的东西塞进 common** —— 教训：i3status-rust 曾放在 common 当公共配置，实际 pain 和笔记本（双电池）版本完全不同。

### 3.4 hostname 和目录名对不上？

占位符目录名默认用 hostname。若机器 hostname 与目录名不同（例：笔记本 hostname 是 `K1llingMyL0v3`，目录叫 `thinkpadx250`），在 `dotfiles/sync.sh` 顶部 `HOST_ALIASES` 登记一行：

```bash
HOST_ALIASES=( "K1llingMyL0v3:thinkpadx250" )
```

## 4. 收尾验证

```bash
~/nix/nixos/dotfiles/sync.sh list              # 托管应用全部 ✅
~/nix/nixos/dotfiles/sync.sh diff              # 无意外差异
home-manager switch --flake ~/nix/nixos#pakiknowledge   # 用户级大包 (krita/libreoffice/gimp)
```

## 5. 常见场景

### 旧机器迁到新机器

```bash
# 旧机器: 先把 live 配置回写仓库
~/nix/nixos/dotfiles/sync.sh sync
cd ~/nix/nixos && git add . && git commit

# 新机器: clone → 走上面 2/3 流程 → deploy
```

### 从别的发行版带来配置

先把想要的配置**挑进仓库**（common 或对应 host 层），再 `deploy`。
不要让 `deploy` 反手覆盖你没备份的东西（虽然有 `.dotfiles-backup/` 兜底，别依赖）。

### 改机器代号

三处一起改，别只改一半：
- `flake.nix` 的 `nixosConfigurations.<Name>` 和 `#<Name>`
- `hosts/<Name>/`（NixOS 层目录）
- `dotfiles/hosts/<name>/` + `HOST_ALIASES` 映射（dotfiles 层）

## 6. 回滚 / 弃用 flake

本流程从不碰 `/etc/nixos`，所以想回到 channel 模式很简单：
把你想用的 channel 配置放回 `/etc/nixos`（如果 `/etc/nixos` 里还是新机默认文件，直接改它也行），然后：

```bash
sudo nixos-rebuild switch
```

它读 `/etc/nixos` 构建，与 flake 仓库互不影响。
