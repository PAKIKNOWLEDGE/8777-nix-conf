{ config, pkgs, ... }: {
  networking.hostName = "pain";
  imports = [ ./hardware.nix ];
  environment.systemPackages = with pkgs; [
    macchina # hyfetch用的
    zed-editor
  ];

 /*
 这个时候有彦祖要疑惑了 这段差异化配置到底是哪来的
 是这样的 这显示器是我花了仅仅六十块买的 廉价的VGA线不能把EDID正确的传入内核
 我用了一个星期的1024x768才发现 下面这一段强行注入正确的分辨率
 对不起 我的幸福都是装的
 */ 
  hardware.display.edid.modelines."1366x768_60" =
    "85.25 1368 1440 1576 1784 768 771 781 798 -hsync +vsync";
  hardware.display.outputs."VGA-1".edid = "1366x768_60.bin";
}
