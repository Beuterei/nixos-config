{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # Use the same nixpkgs revision as this flake.
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Not in nixpkgs yet.
    sofka = {
      url = "github:nklmilojevic/sofka";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = { nixpkgs, sofka, ... }@inputs: let
    overlays = [ sofka.overlays.default ];

    mkSystem = import ./lib/mksystem.nix {
      inherit overlays nixpkgs inputs;
    };
  in {
    nixosConfigurations.helios = mkSystem "helios" {
      system = "x86_64-linux";
      user = "luis";
    };
  };
}
