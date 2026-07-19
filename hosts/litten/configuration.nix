{ pkgs, pkgs', nixosModules, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_6_12;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    supportedFilesystems = [ "zfs" ];
    initrd.kernelModules = [ "zfs" ];
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
  };

  networking = {
    hostName = "litten";
    hostId = "60ad1747";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
  };

  time.timeZone = "Europe/Madrid";

  environment.sessionVariables = {
    WLR_DRM_NO_MODIFIERS = "1";
    NIXOS_OZONE_WL = "1";
  };

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

    gnome.gnome-keyring.enable = true;

    vault = {
      enable = true;
      package = pkgs.vault-bin;

      extraConfig = ''
        ui = true
      '';
    };
  };

  # TODO: Use sops-nix for secrets?
  users = {
    users = {
      sekun = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
      };

      stream = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
      };
    };
  };

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
      settings.screencast = {
        chooser_type = "simple";
        chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
      };
    };
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };

  programs = {
    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    fish.enable = true;

    kdeconnect.enable = true;

    obs-studio = {
      enable = true;

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-vaapi
      ];
    };

    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };

    foot = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        main = {
          font = "CommitMono Nerd Font:size=12";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    kdePackages.akregator
    kdePackages.alligator
    kdePackages.merkuro
    kdePackages.audiotube
    tailscale
    google-chrome
    vlc
    hledger
    anki-bin
    pkgs'.obsidian
    steam
    ripgrep

    wl-clipboard
    mako
    i3status-rust
    grim
    slurp

    mpv

    home-manager
    swayidle
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.commit-mono
    nerd-fonts.jetbrains-mono
    myfonts.berkeley-mono-1009-ligatures
    comic-mono
  ];

  system.stateVersion = "26.05";

  home-manager = {
    users.sekun = ../../modules/home-manager/sekun.nix;
    users.stream = ../../modules/home-manager/stream.nix;
    extraSpecialArgs = {
      inherit pkgs nixosModules;
    };
  };
}
