{ ... }: {
  networking.hostName = "Gater";
  imports = [ ./hardware.nix ];
  # Hermes 网关：合盖不休眠（无论插电/电池/底座）
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };
}
