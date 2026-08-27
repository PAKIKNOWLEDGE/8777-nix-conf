{ ... }: {
  networking.hostName = "Gater";
  imports = [ ./hardware.nix ];
}
