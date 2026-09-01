{
  description = "PAKI KNOWLEDGE NixOS Configuration";

  nixConfig = {
    extra-substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.nju.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-25-11.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-25-11, home-manager, ... }: {
    nixosConfigurations = {
      ThinkPadX250 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./hosts/ThinkPadX250
        ];
      };
      pain = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./hosts/pain
        ];
      };
      T430 = nixpkgs.lib.nixosSystem{
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./hosts/T430
        ];
      };
    };

    homeConfigurations.pakiknowledge = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = {
        pkgs-25-11 = nixpkgs-25-11.legacyPackages.x86_64-linux;
      };
      modules = [ ./home.nix ];
    };
  };
}
