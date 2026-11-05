# System account for luis. Home-manager config is users/luis/home-manager.nix.
{ pkgs, ... }:

{
  users.users.luis = {
    isNormalUser = true;
    description = "Luis";
    home = "/home/luis";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDb4sfeuO2Tjo7d/AExa5UWpR8+l8nnD5Uh82XqjfSXUJpxV4MVhzEPPbQZoZwqEtEyMQSpWEkBt4LL6miHLNwdkF3ZBo6wW2WGwXycE3r+hZ27YhQI5mWRGRG76AcVxQbE/qXemmAlhPFjVtdbA9uQ7y59lqTgTNp5uzZkWe4fRJyDjIZTYJlmKARs0L4fa46DUPH2PS0nDWaQ+2iUPslYbBIhLGauvz8JwcT/vWNYDFZMMkL+bnbOociBJ5OE7eCrA5TRVRZodRTjf01lVyR1/fH0EUDlEZyPNsXQxNHQn3VSwttPi0lNKQh+/n/s8MEsd9degXp/Ca3ag1PiHTqNYYrJZhj/wKEIMDYrTpBJ7BOryWQvXRXt0ApOMMlmG2qB7b6ww1DiGUP2u6+64BVBBUVO47zd8+UPoOCj4+ZmTMU8TA6pPjY4xFeGNMfwEuYe7Kx8pJJW8mHshRDIwrcol0Ata3kMsGg0vFjQqetcZT9fZI2hc5biXIybPmC7WbU= beuluis"
    ];
  };

  # Puts zsh in /etc/shells so it is a valid login shell. compinit stays
  # in home-manager, which owns the interactive config.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
  };
}
