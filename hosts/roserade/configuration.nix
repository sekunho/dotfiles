# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs', agenixPackage, ... }:
let
  pubKeys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINI269n68/pDDfMjkPaWeRUldzr1I/dWfUZl7sZPktwCAAAABHNzaDo= software@sekun.net"
  ];
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  nixpkgs.config.allowUnfree = true;

  age = {
    secrets = {
      emojiedDBPassword.file = "/root/secrets/emojiedDBPassword.age";
      emojiedDBCACert.file = "/root/secrets/emojiedDBCACert.age";
      tailscaleKey.file = "/root/secrets/tailscaleKey.age";
    };

    identityPaths = [ "/root/.ssh/id_mew_root" ];
  };

  networking = {
    hostName = "roserade";
    usePredictableInterfaceNames = false;
    useDHCP = false;
    interfaces.eth0.useDHCP = true;

    firewall = {
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      allowedTCPPorts = [ 22 25565 ];
    };
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

    settings.trusted-users = [ "root" "@wheel" ];
  };

  environment.systemPackages = with pkgs; [
    inetutils
    mtr
    sysstat
    htop
  ];

  users.users = {
    root = {
      openssh.authorizedKeys.keys = pubKeys;
    };

    grassknot = {
      isNormalUser = true;
      home = "/home/grassknot";
      description = "Grass Knot";
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = pubKeys;
    };
  };

  services = {
    tailscale = {
      enable = true;
      package = pkgs'.tailscale;
    };

    openssh = {
      enable = true;
      permitRootLogin = "yes";
      passwordAuthentication = false;
    };

    minecraft-server = {
      enable = true;
      eula = true;
      declarative = true;
      package = pkgs'.minecraft-server;

      jvmOpts = ''
        -Xms512M
        -Xmx3072M
        -XX:+UseG1GC
        -XX:+CMSIncrementalPacing
        -XX:+CMSClassUnloadingEnabled
        -XX:ParallelGCThreads=2
        -XX:MinHeapFreeRatio=5
        -XX:MaxHeapFreeRatio=10
      '';

      serverProperties = {
        online-mode = false;
        server-port = 25565;
        gamemode = "survival";
        motd = "sekun deez nuts, now 24/7 and with lower ping!";
        max-players = 20;
        difficulty = "hard";
      };
    };
  };

  systemd.services = {
    tailscale-autoconnect = {
        description = "Automatic connect to Tailscale";

        after = [ "network-pre.target" "tailscale.service" ];
        wants = [ "network-pre.target" "tailscale.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig.Type = "oneshot";

        script = with pkgs; ''
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

  system.stateVersion = "22.11"; # Did you read the comment?
}
