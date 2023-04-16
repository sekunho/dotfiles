# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs', agenixPackage, ... }:
let
  pubKeys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCUboqku5i0dRaOoTZab2aAtD6WWL5eCPhBQett0bVYYzWupKywA+f/HKy6TBk+syQ9mJ4tf9uBt1bsrpoYIlxzjpVj/iNU+jPxlQJl02Rmryq8dO0DaTh7gTpwZXx4MVUdbI4eV8CZ2tEBYIpPpuPjs8h7014RQJfImrXXo4DBEOTrYZ+GcPR1ITCJHMwMbv4MC+2Qvas67mEfvDAzhFqNR0srOplyRrzmFsNu2XBSjiZVsKjWsG90F21vf+yXfkFHfVILWCYxMumL+CC6rotlKlReMenuMgWhSGBxz2N2P6KifqgIHSMRfp+aVeTwIQTuUSuPFkO4PjNXkgEQvKakOOb/pSruO7fyMWowbVVONg+m+L+SCdrjC4ulxz5VOSdPtY0ZNS29QlwT6lSlCKcCQ4R0RtY+lWsLGUaPApxjqj4gVTEGDFFEx6NUQnhOZcNLDSKtAzIfxWjhLhsyTOVGxH0qTk9a0wbw/NA22eRx3iKLQ4qpF+tj5ow/6h2tywyTiDeXd9MPrOZazy+X8emwRUXvgW1gb6zMmM80/XDc7h/ojfiK5Wg2mkK/L9AksTJeV/EmX5XTNBY5Rl+anXMyh7MnYf9OEX4Ts3hBtdzJWCaQe793E6q14zmZgXP/N4Lj7YawtpFcHk5sw76KYG8tCy7ppexJVYtUA33HXULJnQ== devops@sekun.net"
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
      allowedTCPPorts = [ 22 ];
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
