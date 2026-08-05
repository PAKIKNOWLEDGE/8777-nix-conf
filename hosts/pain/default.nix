{ config, pkgs, ... }: {
  networking.hostName = "pain";
  imports = [ ./hardware.nix ];
  programs.niri.enable = true;
  environment.systemPackages = with pkgs; [
    macchina # hyfetch用的
    zed-editor
  ];

  # VGA EDID 修复 — 显示器不发送 EDID，手动注入
  hardware.display.edid.modelines."1366x768_60" =
    "85.25 1368 1440 1576 1784 768 771 781 798 -hsync +vsync";
  hardware.display.outputs."VGA-1".edid = "1366x768_60.bin";
}
