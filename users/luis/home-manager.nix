# User environment for luis. Wired in by lib/mksystem.nix.
{ inputs, currentSystemName, ... }:

{ pkgs, ... }:

{
  home.username = "luis";
  home.homeDirectory = "/home/luis";

  # Do not change after the first activation.
  home.stateVersion = "26.05";

  programs.git = {
    enable = true;
    settings = {
      user.name = "Luis Beu";
      user.email = "me@luisbeu.de";
      init.defaultBranch = "main";
      core.editor = "vim";
    };
  };

  # Points at the key. The private key is not in this repo: a Nix
  # source would be copied into the world-readable Nix store.
  programs.ssh = {
    enable = true;
    matchBlocks."github.com" = {
      user = "git";
      identityFile = "~/.ssh/beuluis";
      identitiesOnly = true;
    };
  };

  home.packages = [
  ];
}
