{ config, pkgs, ... }: {
  networking.hostName = "K1llingMyL0v3";
  imports = [ ./hardware.nix ];
  # Lix (lix.systems): 社区维护的 nix 分叉, 对用户命令完全兼容.
  # 只在本机启用, pain / T430 不受影响.
  # 待人执行: nixos-rebuild switch --flake .#ThinkPadX250, 然后 nix --version
  nix.package = pkgs.lix;
  environment.systemPackages = with pkgs; [
    tlp
  ];

}
