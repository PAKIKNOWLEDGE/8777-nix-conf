{ config, pkgs, ... }: {
  networking.hostName = "PainkyCrush";
  imports = [ ./hardware.nix ];
  environment.systemPackages = with pkgs; [
    macchina                           # hyfetch用的
    zed-editor
    nil # for zed's LSP
    nixd # 同上
  ];

  
}
