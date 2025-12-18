{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_12;

    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    supportedFilesystems = [ "zfs" ];
    initrd.kernelModules = [ "zfs" ];
  };

  networking = {
    hostName = "litten";
    hostId = "60ad1747";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  services = {
    # Enable the X11 windowing system.
    xserver.enable = true;

    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
    desktopManager.plasma6.enable = true;
    tailscale.enable = true;

    # Enable sound.
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    vault = {
      enable = true;
      package = pkgs.vault-bin;

      extraConfig = ''
        ui = true
      '';
    };

    # coredns = {
    #   enable = true;
    #   config = ''
    #     .:53 {
    #        bind 10.0.1.74
    #        bufsize 1232
    #        acl {
    #                allow net 10.0.0.1/23
    #                block
    #        }
    #        hosts {
    #                reload 0
    #                fallthrough
    #        }
    #        cache {
    #                success 4096
    #                denial  1024
    #                prefetch 512
    #        }
    #        errors
    #        log
    #     }
    #   '';
    # };
  };


  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    users.sekun = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];

      packages = with pkgs; [
        tree
        discord
      ];
    };
  };

  programs = {
    firefox.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    wget
    kdePackages.akregator
    kdePackages.alligator
    tailscale
    obs-studio
    vlc
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.commit-mono
    myfonts.berkeley-mono-1009-ligatures
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "25.05";
}
