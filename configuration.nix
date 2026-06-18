# 编辑此配置文件以定义系统上应安装的内容。
# 帮助信息可在 configuration.nix(5) 手册页和 NixOS 手册中找到
# （可通过运行 ‘nixos-help’ 访问）。

{ config, pkgs, ... }:

{
  # 导入硬件扫描的结果。
  # ── imports 是"模块组合"机制 ──
  # configuration.nix 不是"一个文件描述整个系统"，而是"一个入口文件，import 其他模块"
  # 每个 import 的文件都可以声明 boot、services、environment 等选项
  # NixOS 在构建时把所有这些声明合并成一个系统
  imports =
    [ ./hardware-configuration.nix   # 硬件配置（自动生成，不变） 在迁移时，此部分是不可共通的
    ];

  # ----- 引导程序 -----
  # 使用 systemd-boot 作为 UEFI 引导管理器。
  boot.loader.systemd-boot.enable = true;
  # 允许 systemd-boot 修改 EFI 变量（安装时自动配置）。
  boot.loader.efi.canTouchEfiVariables = true;
  # 限制引导菜单保留最近 5 个 generation，防止无限堆积
  boot.loader.systemd-boot.configurationLimit = 5;

  # ----- 网络 -----
  # 设置主机名。
  networking.hostName = "K1llingMyL0v3";
  # 启用 NetworkManager
  networking.networkmanager.enable = true;

  # 如果需要配置网络代理，请取消注释并修改
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # ----- 时区和本地化 -----
  # 设置时区为中国标准时间。
  time.timeZone = "Asia/Shanghai";

  # 系统默认语言环境（影响日期、数字等格式）。
  i18n.defaultLocale = "zh_CN.UTF-8";

  # 为不同分类（地址、货币等）单独指定语言环境。
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # ----- 图形界面和显示服务器 (X11) -----
  # 启用 X11 窗口系统。
  services.xserver.enable = true;

  # 启用 XFCE 桌面环境
  # LightDM → SDDM
  services.displayManager.sddm.enable = true;              # 之前写错了（旧名 services.xserver.displayManager.sddm）
  services.xserver.desktopManager.xfce.enable = true;     # XFCE
  # i3  
  services.xserver.windowManager.i3.enable = true;

  # 设置键盘布局为中文
  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  # ----- 打印 -----
  # 启用 CUPS 打印服务（经典打印系统）。
  # 这有啥用？
  services.printing.enable = true;

  # ----- 声音和音频  -----
  # 禁用 PulseAudio（使用 PipeWire 替代）。
  services.pulseaudio.enable = false;
  # 启用 RealtimeKit（为音频服务提供实时调度权限，提升音质和稳定性）。
  security.rtkit.enable = true;
  # 启用 PipeWire（新一代音频/视频服务，推荐现代系统使用）。
  services.pipewire = {
    enable = true;
    alsa.enable = true;          # 支持 ALSA 应用
    alsa.support32Bit = true;    # 支持 32 位 ALSA 应用（游戏、旧软件）
    pulse.enable = true;         # 兼容 PulseAudio 应用（向下兼容）
    # jack.enable = true;        # 如果需要 JACK 专业音频应用，取消注释
    # media-session.enable = true; # 默认已启用，无需重复配置
  };

  # 触摸板支持（通常已在桌面环境中默认启用，此处保留可选项）。
  # 上面的，我用i3wm你不炸了吗
  services.libinput.enable = true;                         # 旧名 services.xserver.libinput

  # ----- 用户账户 -----
  # 定义你的用户。
  users.users."pakiknowledge" = {       # 注意：在迁移的时候这个地方非常重要！！如果用户名不一致了系统会broken。
    isNormalUser = true;                # 普通用户，而非系统服务账户
    description = "PAKI KNOWLEDGE";     # 我的全名
    extraGroups = [ "networkmanager" "wheel" ]; # 加入这些组以获取网络管理和 sudo 权限
    shell = pkgs.fish;                  # 默认 shell 设为 fish（不用 chsh，声明式搞定）
    # 用户级别的软件包（只会安装给这个用户，不会影响其他用户）。
    packages = with pkgs; [
      # ----- 日常 CLI -----
      bat ripgrep fd fzf eza lazygit zoxide yazi
      btop htop fastfetch tree hyfetch

      # ----- i3 生态 -----
      rofi picom dunst nitrogen flameshot xautolock maim i3lock xclip

      # ----- 终端 -----
      wezterm starship

      # ----- 编辑器 -----
      neovim kdePackages.kate

      # ----- 个人工具 -----
      go-musicfox gh haskellPackages.greenclip

      # ----- 字体 -----
      pkgs.nerd-fonts.jetbrains-mono
    ];
  };

  # 启用 Firefox（使用 NixOS 的“程序模块”方式安装，会自动处理浏览器配置）。
  programs.firefox.enable = true;

  programs.fish.enable = true;

  # ----- 软件包管理 -----
  # 允许安装许可证不自由的软件包（如 Chrome、Nvidia 驱动等）。
  nixpkgs.config.allowUnfree = true;

  # ----- 系统级软件包（所有用户都可用）-----
  #   systemPackages → /run/current-system/sw/bin/、所有用户
  #   users.users.xxx.packages → ~/.nix-profile/bin/、仅当前用户
  #
  # 大件软件、系统工具放这里；个人 CLI 工具放 users.users.pakiknowledge.packages
  # 注意：输入法（如 fcitx5）不应添加在这里，它们有专门的配置选项。
  # note1:在nix语言中，列表构造优先级竟然是高于函数对，这太可怕了
  # 然而更恐怖的是 如果不适用括号 列表会认为它接受了两个元素
  environment.systemPackages = with pkgs; [
    # Error1：kate 是 KDE 的编辑器，在较新的 Nixpkgs 中需要指定 kdePackages 前缀。
    kdePackages.kate            # 挚爱
    neovim                      # lazy
    fastfetch                   #
    # 注意：Nix 列表元素前的空格不能多！列表解析是严格的，多一个空格会被当成不同标识符
    git                         # 我（事实上，git means '饭桶'，不过本人近日体重43kg）
    # 2026-06-17 17:10
    wget                        # 迅雷下载破解版
    curl                        # 迅雷下载无敌版
    htop                        # 任务管理器黑客帝国版
    btop                        # 他俩有啥区别 我只知道一个对于terminal渲染尺寸有要求
                                # 到底是哪个呢.....
    tree                        # 歪脖子树 （划掉）以树状图显示目录结构
    unzip                      # 360一键压缩破解版
    nodejs                     # agent 启动
    fish                       # 哦哦。
    clash-verge-rev            # 代理客户端，大陆用户必备
    gh                         # GitHub CLI，给 GitHub 拉 dotfiles 用的
    gcc                        # nvim-treesitter 编译 parser 需要 C 编译器
    tree-sitter                # nvim-treesitter 编译 parser 需要 CLI
  ];

  # ----- 可选程序配置（需要额外配置的服务）-----
  # programs.mtr.enable = true;           # 网络诊断工具
  # programs.gnupg.agent = {
  #   enable = true;                      # 启用 GnuPG 密钥代理
  #   enableSSHSupport = true;            # 让 SSH 使用 GnuPG 代理
  # };

  # ----- 系统服务 -----
  # services.openssh.enable = true;       # 启用 OpenSSH 远程访问服务

  # ----- 防火墙 -----
  # networking.firewall.allowedTCPPorts = [ ... ];   # 开放指定 TCP 端口
  # networking.firewall.allowedUDPPorts = [ ... ];   # 开放指定 UDP 端口
  networking.firewall.enable = false;                # 关了，被这玩意儿恶心太多次了

  # ----- 系统状态版本 -----
  # 此值决定了首次安装此系统时，状态数据（如文件位置、数据库版本）的默认设置。
  # 保持此值为最初安装的版本即可，除非你明确知道需要更改。
  system.stateVersion = "26.05";

  # ----- 8777 的个人定制部分 -----

  # 使用中科大（USTC）镜像源加速软件包下载。
  # 这里将中科大源设置为优先，官方源作为备用。
  nix.settings = {
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org/"
    ];
  };

  # 自动垃圾回收——每周清理 7 天前的旧 generation
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ----- 输入法配置 (fcitx5) -----
  # 这是启用中文输入法的标准方式，请勿将 fcitx5 添加到 systemPackages。
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";                     # 使用 fcitx5 框架
    fcitx5.addons = with pkgs; [
      fcitx5-rime                        # 中州韵输入法引擎（功能强大，支持各种方案）
      fcitx5-gtk                         # 为 GTK 程序提供输入法支持
      qt6Packages.fcitx5-configtool      # 图形化配置工具
    ];
  };
}

