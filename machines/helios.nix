# Helios: desktop that also runs a single-node k3s cluster.
{ config, lib, pkgs, currentSystemName, currentSystemUser, ... }:

{
  imports = [
    ./hardware/helios.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = currentSystemName;
  networking.networkmanager.enable = true;
  networking.firewall.enable = true;

  # Nothing is published to the internet. Public HTTP(S) will arrive
  # through a Cloudflare Tunnel (outbound). LAN clients may use SSH,
  # DNS, and Traefik. Cluster pods reach those services on ClusterIPs
  # and do not need these host ports.
  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -s 192.168.1.0/24 -p tcp -m multiport --dports 22,53,80,443 -j nixos-fw-accept
    iptables -A nixos-fw -s 192.168.1.0/24 -p udp --dport 53 -j nixos-fw-accept
  '';
  networking.firewall.extraStopCommands = ''
    iptables -D nixos-fw -s 192.168.1.0/24 -p tcp -m multiport --dports 22,53,80,443 -j nixos-fw-accept || true
    iptables -D nixos-fw -s 192.168.1.0/24 -p udp --dport 53 -j nixos-fw-accept || true
  '';
  networking.firewall.trustedInterfaces = [
    "cni+"
    "flannel.1"
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  # English UI, German formats (dates, currency, paper).
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.firefox.enable = true;

  # Always-on host: ignore sleep and the lid switch.
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  services.logind.settings.Login = {
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;

  # Open NVIDIA kernel module, required for container GPU access.
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };

  hardware.nvidia-container-toolkit.enable = true;

  programs.coolercontrol.enable = true;

  # CDI so containers can see the GPU.
  virtualisation.docker = {
    enable = true;
    daemon.settings.features.cdi = true;
  };

  # Single-node cluster. 644 so the logged-in user can read the kubeconfig.
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = [ "--write-kubeconfig-mode=644" ];
  };

  # Default editor for every account. SOPS reads EDITOR.
  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  environment.sessionVariables = {
    KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    HELM_PLUGINS = "${pkgs.kubernetes-helmPlugins.helm-diff}";
    VISUAL = "vim";
  };

  # Key-only SSH, limited to the configured user. Port 22 is opened
  # for the LAN in the firewall rules above, not by this module.
  services.openssh = {
    enable = true;
    openFirewall = false;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = [ currentSystemUser ];
      PermitRootLogin = "no";
    };
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    btop
    nvtopPackages.nvidia
    nodejs_24
    wget
    kubectl
    kubernetes-helm
    helmfile
    kustomize
    k9s
    fluxcd
    sops
    git
    go-task
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Do not change after the first install.
  system.stateVersion = "26.05";
}
