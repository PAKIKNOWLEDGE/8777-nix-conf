{ config, pkgs,  ... }: {
  networking.hostName = "K1llingMyL0v3";
  imports = [ ./hardware.nix ];
  environment.systemPackages = with pkgs; [
    helix
    tlp
  ];



}
