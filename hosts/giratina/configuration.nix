{ modulesPath, lib, config, pkgs, pkgs', agenixPackage, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # TODO: Add secrets for Tailscale
  age = {
    secrets = {};
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

  nix = {
    package = pkgs.nixVersions.nix_2_13;

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    # Binary Cache for Haskell.nix
    settings.trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "loony-tools:pr9m4BkM/5/eSTZlkQyRt57Jz7OMBxNSUiMC4FkcNfk="
    ];

    settings.substituters = [
      "https://cache.iog.io"
      "https://iohk.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.zw3rk.com"
    ];
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

  systemd = {
    services = {
      # FIXME: https://github.com/NixOS/nixpkgs/issues/180175
      NetworkManager-wait-online.enable = false;

      tailscale-autoconnect = {
        description = "Automatic connect to Tailscale";

        after = [ "network-pre.target" "tailscale.service" ];
        wants = [ "network-pre.target" "tailscale.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig.Type = "oneshot";

        script = with pkgs'; ''
          sleep 2

          status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"

          if [ $status = "Running" ]; then
            exit 0
          fi

          tailscale_key=$(cat ${config.age.secrets.tailscaleKey.path})

          ${tailscale}/bin/tailscale up -authkey $tailscale_key
          '';
      };
    };
  };

  services = {
    tailscale = {
      enable = true;
      package = pkgs'.tailscale;
    };

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
