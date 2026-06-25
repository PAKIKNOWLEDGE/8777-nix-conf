{ config, pkgs, ... }:

{
  # ── 用户信息 ──
  home.username = "pakiknowledge";
  home.homeDirectory = "/home/pakiknowledge";

  # 与 configuration.nix 中的 system.stateVersion 保持一致
  home.stateVersion = "26.05";

  # ── 用户级包（非系统必需） ──
  home.packages = with pkgs; [
    krita                       # 数字绘画
    onlyoffice-desktopeditors   # 办公套件
  ];

  # HM 自身需要启用才能正常工作
  programs.home-manager.enable = true;
}
