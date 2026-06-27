{ config, pkgs, ... }:
{
  # 在 home.nix 里允许非自由软件
  nixpkgs.config = {
    allowUnfree = true;
  };
  # ── 用户信息 ──
  home.username = "pakiknowledge";
  home.homeDirectory = "/home/pakiknowledge";

  # 与 configuration.nix 中的 system.stateVersion 保持一致
  home.stateVersion = "26.05";

  # ── 用户级包（非系统必需） ──
  home.packages = with pkgs; [
    # krita                       # 数字绘画
  /*
  我很难说nix本质是不是一个上游炸掉下游炸光的东西。但是呢，目前的情况就是处于stable 26.05
  (*it's means 2026.5)
  krita6.0.1的字体菜单炸了，目前这个部分我还是需要用profile install来单独处理:
  nix profile install nixpkgs/nixos-25.11#krita
  */
    libreoffice   # 办公套件 这吊货编译了12分钟
    sarasa-gothic # 更纱黑体
    gimp #adobe?
  ];

  # HM 自身需要启用才能正常工作
  programs.home-manager.enable = true;
}
