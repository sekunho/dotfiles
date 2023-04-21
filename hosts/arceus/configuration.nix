{ lib, config, pkgs, pkgs', fonts, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;

  networking = {
    hostName = "arceus";
    hostId = "7c48531f";
    networkmanager.enable = true;
    useDHCP = false;
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    kernelPackages = pkgs.linuxPackages_6_1;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = [ "zfs" ];

    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/29dbd865-825c-48ea-9123-3e28116c72d6";
        preLVM = true;
      };
    };
  };

  virtualisation = {
    libvirtd.enable = true;
    docker.enable = true;
  };

  time = {
    timeZone = "Asia/Singapore";
    hardwareClockInLocalTime = true;
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.

  # Should look into how to split to modules and all that.
  programs = {
    bash = {
      interactiveShellInit = ''
        eval "$(direnv hook bash)"
      '';

      shellAliases = { doom = "~/.emacs.d/bin/doom"; };
    };

    fish = {
      enable = true;
      shellAliases = { doom = "~/.emacs.d/bin/doom"; };

      interactiveShellInit = ''
        direnv hook fish | source
      '';
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  systemd = {
    user.services = {
      /* nitrogen = { */
      /*   description = "Sets wallpaper"; */
      /*   wantedBy = [ "graphical-session.target" ]; */
      /*   partOf = [ "graphical-session.target" ]; */
      /*   script = "${pkgs.nitrogen}/bin/nitrogen --set-scaled /home/sekun/Pictures/1244598.jpg"; */
      /*   serviceConfig.Type = "exec"; */
      /* }; */
    };

    services = {
      # Mouse lags sometimes with this and it's so damn annoying.
      /* aorus-b550i-suspend-fix = { */
      /*  description = "Fixes the 'wakes up immediately after suspend' issue"; */
      /*  wantedBy = [ "multi-user.target" ]; */
      /*  after = [ "multi-user.target" ]; */
      /*  serviceConfig.Type =  "oneshot"; */

      /*  script = '' */
      /*    # TODO: Remove this when Gigabyte fixes this via firmware update */
      /*    if ${pkgs.ripgrep}/bin/rg --quiet '\bGPP0\b.*\benabled\b' /proc/acpi/wakeup; then */
      /*      echo GPP0 > /proc/acpi/wakeup */
      /*    fi */

      /*    # TODO: Find a better way for the stupid mouse to not wake up from suspend */
      /*    echo disabled > /sys/bus/usb/devices/3-4/power/wakeup */
      /*  ''; */
      /* }; */

      # FIXME: https://github.com/NixOS/nixpkgs/issues/180175
      NetworkManager-wait-online.enable = false;


      # https://gist.github.com/DavidAce/67bec5675b4a6cef72ed3391e025a8e5
      nvidia-tdp-limit = {
        description = "Break NVIDIA's kneecaps";

        serviceConfig = {
          Type = "oneshot";
          ExecStartPre = "/run/current-system/sw/bin/nvidia-smi -pm 1";
          ExecStart = "/run/current-system/sw/bin/nvidia-smi -pl 200";
        };
      };
    };

    timers = {
      # https://gist.github.com/DavidAce/67bec5675b4a6cef72ed3391e025a8e5
      nvidia-tdp-limit = {
        wantedBy = [ "timers.target" ];
        timerConfig.OnBootSec = 5;
      };
    };
  };

  services = {
    picom = {
      enable = false;

      settings = {
        inactive-opacity = 0.90;
        active-opacity = 0.97;
        frame-opacity = 0.97;

        blur = {
          method = "kawase";
          strength = 9;
          background = false;
          background-frame = false;
          background-fixed = false;
        };
      };
    };

    dbus.enable = true;

    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      exportConfiguration = true;

      # WM/DE

      ## i3
      /* desktopManager = { xterm.enable = false; }; */
      /* displayManager = { defaultSession = "none+i3"; }; */

      /* windowManager.i3 = { */
      /*   enable = true; */
      /*   package = pkgs'.i3; */

      /*   extraPackages = with pkgs; [ */
      /*     dmenu */
      /*     i3status */
      /*     i3lock */
      /*     i3blocks */
      /*   ]; */
      /* }; */

      ## Gnome
      displayManager.gdm = {
        enable = true;
      };
      desktopManager.gnome.enable = true;

      /* monitorSection = '' */
      /*   VendorName     "Unknown" */
      /*   ModelName      "Huawei Technologies Co., Ltd MateView" */
      /*   HorizSync       45.0 - 180.0 */
      /*   VertRefresh     48.0 - 75.0 */
      /* ''; */

      /* deviceSection = '' */
      /*   VendorName     "NVIDIA Corporation" */
      /*   BoardName      "NVIDIA GeForce RTX 3090 Ti" */
      /*   Option         "TripleBuffer" "On" */
      /* ''; */

      /* screenSection = '' */
      /*   DefaultDepth    24 */
      /*   Option         "Stereo" "0" */
      /*   Option         "nvidiaXineramaInfoOrder" "DFP-1" */
      /*   Option         "metamodes" "3840x2560_60 +0+0 {ForceCompositionPipeline=On}" */
      /*   Option         "SLI" "Off" */
      /*   Option         "MultiGPU" "Off" */
      /*   Option         "BaseMosaic" "off" */
      /*   SubSection     "Display" */
      /*       Depth       24 */
      /*   EndSubSection */
      /* ''; */
    };

    tailscale = {
      enable = true;
      package = pkgs'.tailscale;
    };

    # For server mode
    emacs = {
      package = pkgs.emacsNativeComp;
      enable = true;
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };

  sound.enable = true;

  hardware = {
    pulseaudio.enable = true;
    opengl.enable = true;

    # NOTE: nvidia-drm.modeset=1
    nvidia.modesetting.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    groups = {
      shared = {
        members = [ "sekun" "noodle" ];
      };
    };

    users = {
      sekun = {
        shell = pkgs.fish;
        isNormalUser = true;
        createHome = true;

        extraGroups = [
          "wheel"
          "networkmanager"
          "docker"
          "libvirtd"
        ];

        packages = with pkgs; [
          xournalpp
          signal-desktop
          pkgs'.discord
          tdesktop
          element-desktop
          pkgs'.fractal-next
          obsidian

          # Video editing
          libsForQt5.kdenlive

          # Streaming
          obs-studio

          davinci-resolve

          hledger
          hledger-web
          hledger-ui
          wiki-tui
          transmission-gtk

          mcrcon
          pkgs'.prismlauncher

          # Networking
          # ciscoPacketTracer8

          imagemagick
          krita

          yt-dlp

          # VM stuff
          virt-manager
          virt-viewer

          pkgs'.cloudflared
          pkgs'.insomnia
        ];
      };

      noodle = {
        shell = pkgs.fish;
        isNormalUser = true;
        createHome = true;

        extraGroups = [
          "wheel"
          "networkmanager"
          "docker"
          "libvirtd"
        ];

        packages = with pkgs; [
          slack
          krita
          pkgs'.insomnia
          awscli2
          obs-studio
          obsidian
          pkgs'.discord

          pkgs'._1password-gui
          pkgs'.cloudflared
          handbrake
        ];
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with pkgs.gst_all_1; [
      gst-plugins-good
      gst-plugins-bad
      gst-plugins-ugly
      gst-libav
    ]);

    systemPackages = with pkgs; [
      lxappearance
      nitrogen
      pavucontrol

      # Essential system tools
      pkgs.tailscale
      git
      htop
      powertop
      neofetch
      doas
      xorg.xeyes
      vulkan-tools
      lshw
      agenix
      tree
      rclone # Encrypt files and make a remote backup
      glxinfo # View GPU-related information
      radeontop # Monitor GPU usage for AMD
      chrome-gnome-shell

      # mullvad-vpn

      libreoffice
      linux-wifi-hotspot

      pkgs'.docker-compose

      # Media
      ffmpeg
      youtube-dl
      vlc

      # Disks and whatnot
      ventoy-bin
      gnome.gnome-boxes

      # Dev tools
      kitty
      xclip
      wget
      curl
      gnupg # something i need for git that i haven't looked into
      nix-du # i forgot what this was
      graphviz # visualize stuff in graphs
      nixfmt # make nix code look pretty and nice
      cloc # how many spaghetti lines of code have I written already?
      pkgs'.direnv # no more cluttering global namespaces; now with flakes!
      pkgs'.nix-direnv # nix integration for direnv
      asciinema
      wireguard-tools

      # Database
      sqlitebrowser
      pgadmin4

      # I didn't install `doom-emacs` with nix so I gotta declare some system
      # dependencies for it to work normally. Might look into using nix later.
      ripgrep
      findutils
      fd
      shellcheck
      pandoc
      gnumake
      libtool
      editorconfig-core-c
      dos2unix
      proselint
      mdl

      zoom-us

      # Customization
      gnome.gnome-tweaks

      # Browsers
      firefox
      google-chrome

      qpdf
      libsForQt5.ksshaskpass
    ];

    pathsToLink = [ "/share/nix-direnv" "/libexec" ];

    sessionVariables = {
      KITTY_CONFIG_DIRECTORY = "/shared/System/dotfiles/config/kitty/";
      KITTY_DISABLE_WAYLAND = "1";
      # MOZ_ENABLE_WAYLAND = "0";
      # PLASMA_USE_QT_SCALING = "1";
      # QT_SCREEN_SCALE_FACTORS="DisplayPort-0=2;DisplayPort-1=2;DisplayPort-2=2;";
    };
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" "Iosevka" ]; })

    fonts.berkeley-mono-1009-ligatures
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    steam.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      # https://github.com/NixOS/nixpkgs/issues/137829
      package = pkgs.neovim-unwrapped;

      # https://github.com/NixOS/nixpkgs/pull/124785#issuecomment-850837745
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            # Airline
            vim-airline
            vim-airline-themes
            vim-airline-clock

            # ASCII diagram editor
            venn-nvim

            # Themes
            gruvbox-nvim

            # Languages, etc.
            direnv-vim
            nvim-lspconfig
            ghcid

            # Usage
            # https://nixos.org/manual/nixpkgs/unstable/#vim
            #
            # Available parsers
            # https://tree-sitter.github.io/tree-sitter/#available-parsers
            (nvim-treesitter.withPlugins (
              plugins: with plugins; [
                tree-sitter-nix

                # This one is too slow for my taste. :(
                # But I don't have anything else. Not a fan of `vim-elixir`.
                tree-sitter-elixir

                # Web front-end stuff
                tree-sitter-typescript
                tree-sitter-javascript
                tree-sitter-html
                tree-sitter-css

                tree-sitter-rust
                tree-sitter-haskell
                tree-sitter-lua

                # Shell
                tree-sitter-fish
                tree-sitter-bash

                tree-sitter-make
              ]
            ))

            todo-comments-nvim
            fidget-nvim

            # I don't know how to categorize this
            plenary-nvim

            telescope-nvim
            # telescope-ui-select-nvim
            # null-ls-nvim

            nvim-web-devicons
            auto-pairs
            trouble-nvim
            vim-commentary
            vim-surround
            which-key-nvim

            rust-vim

            # Magit is unfortunately still king :(
            gitsigns-nvim
          ];
        };

        customRC = ''
          " Has a leading backslash cause vim will think of it as a normal
          " string. Also, not a fan of the forwardslash for the leader key.
          let mapleader = "\<Space>"

          lua << EOF
            ${builtins.readFile ../../config/neovim/init.lua}
          EOF

          ${builtins.readFile ../../config/neovim/init.vim}
        '';
      };
    };
  };

  security = {
    doas = {
      enable = true;

      extraRules = [{
        users = [ "sekun" ];
        persist = true;
        keepEnv = true;
      }];
    };

    sudo.enable = false;
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
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
