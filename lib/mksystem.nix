# Build a NixOS system from a machine name and a user name.
#
#   mkSystem "helios" { system = "x86_64-linux"; user = "luis"; }
#
# Loads machines/<name>.nix, users/<user>/nixos.nix, and
# users/<user>/home-manager.nix.
{ nixpkgs, overlays, inputs }:

name:
{ system, user }:

let
  machineConfig = ../machines/${name}.nix;
  userOSConfig = ../users/${user}/nixos.nix;
  userHMConfig = ../users/${user}/home-manager.nix;
in
nixpkgs.lib.nixosSystem {
  inherit system;

  modules = [
    { nixpkgs.overlays = overlays; }

    { nixpkgs.config.allowUnfree = true; }

    machineConfig
    userOSConfig

    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${user} = import userHMConfig {
        inherit inputs;
        currentSystemName = name;
      };
    }

    # Passed to every module as extra arguments.
    {
      config._module.args = {
        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
        inherit inputs;
      };
    }
  ];
}
