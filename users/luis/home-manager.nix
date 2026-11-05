# User environment for luis. Wired in by lib/mksystem.nix.
{ inputs, currentSystemName, ... }:

{ pkgs, lib, ... }:

{
  home.username = "luis";
  home.homeDirectory = "/home/luis";

  # Do not change after the first activation.
  home.stateVersion = "26.05";

  # Inline history, the same idea as iTerm's command completion.
  # A gray suggestion appears as you type; Right accepts it.
  # Up and Down walk older lines that start with what you have typed.
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    # NixOS zshrc selects the suse prompt (user@host:dir/ >).
    # Same text, with $ instead of >. Bright green as a user, bright red as root.
    # Up and Down are prefix search. zinputrc binds the terminfo keys to
    # the full history, so those are replaced here.
    initContent = lib.mkOrder 1300 ''
      prompt off
      PROMPT='%B%F{%(!.red.green)}%n@%m:%~/ %(!.#.$)%f%b '

      [[ -n $terminfo[kcuu1] ]] && bindkey $terminfo[kcuu1] history-beginning-search-backward
      [[ -n $terminfo[kcud1] ]] && bindkey $terminfo[kcud1] history-beginning-search-forward
      bindkey '^[[A' history-beginning-search-backward
      bindkey '^[[B' history-beginning-search-forward
      bindkey '^[OA' history-beginning-search-backward
      bindkey '^[OB' history-beginning-search-forward
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "Luis Beu";
      user.email = "me@luisbeu.de";
      init.defaultBranch = "main";
    };
  };

  # Points at the key. The private key is not in this repo: a Nix
  # source would be copied into the world-readable Nix store.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."github.com" = {
      User = "git";
      IdentityFile = "~/.ssh/beuluis";
      IdentitiesOnly = true;
    };
  };

  home.packages = [
  ];
}
