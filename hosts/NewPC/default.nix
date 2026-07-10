{ ... }: {
  networking.hostName = "NewPC";

  # 占位：等新机器到了 nixos-generate-config 生成后替换
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/CHANGE-ME";
    fsType = "ext4";
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
