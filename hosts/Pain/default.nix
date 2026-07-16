{ config, pkgs, ... }: {
  networking.hostName = "PainkyCrush";
  imports = [ ./hardware.nix ];

  # ── Pain 专属软件包 ──
  #   这里只放这台机器独有的包，公共包在 configuration.nix 管理
  environment.systemPackages = with pkgs; [
    macchina                           # hyfetch用的

  ];

}
