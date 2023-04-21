{ modulesPath, lib, config, pkgs, pkgs', agenixPackage, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # TODO: Add secrets for Tailscale
  age = {
    secrets = { };
    identityPaths = [ "/home/root/.ssh/id_giratina_rsa" ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINI269n68/pDDfMjkPaWeRUldzr1I/dWfUZl7sZPktwCAAAABHNzaDo= software@sekun.net"
  ];

  networking = {
    hostName = "giratina";
    hostId = "7c48531f";
    networkmanager.enable = true;
    useDHCP = false;
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    initrd.kernelModules = [ "amdgpu" "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_6_1;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = [ "zfs" ];

    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/627d65b7-ff80-43d9-8cb7-b4d379830976";
        preLVM = true;
      };
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  services = {
    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [ htop ];

    loginShellInit = ''
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    '';
  };

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;

    # trace: warning: Strict reverse path filtering breaks Tailscale exit node
    # use and some subnet routing setups
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPorts = [ 22 ];
  };

  system.stateVersion = "22.11";
}
