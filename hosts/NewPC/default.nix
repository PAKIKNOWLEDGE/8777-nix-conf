{ ... }: {
  networking.hostName = "NewPC";
  imports = [ ./hardware.nix ];

  # ── 等你新机器到了，差异配置写这里 ──

  # 硬件相关（触控板、独显等）
  # services.libinput.enable = false;
  # hardware.graphics.enable = true;

  # 想换 Hyprland？
  # programs.hyprland.enable = true;
  # environment.systemPackages = with pkgs; [ waybar wofi ... ];

  # 不想用 i3 了？
  # services.xserver.windowManager.i3.enable = false;
}
