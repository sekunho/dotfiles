{ lib, config, pkgs, pkgs', ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # TODO: Split to nixos modules

  nixpkgs.config.allowUnfree = true;
  nix.settings.auto-optimise-store = true;

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
    docker.package = pkgs'.docker;
  };

  time = {
    timeZone = "Asia/Singapore";
    hardwareClockInLocalTime = true;
  };

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
        export PATH="$HOME/.cargo/bin:$PATH"
        eval (ssh-agent -c)
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
    services = {
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
    dbus.enable = true;

    ntp = {
      enable = true;

      servers = [
        "0.jp.pool.ntp.org"
        "1.jp.pool.ntp.org"
        "2.jp.pool.ntp.org"
        "3.jp.pool.ntp.org"
      ];
    };


    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      exportConfiguration = true;

      # WM/DE

      ## KDE
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;

      deviceSection = ''
        VendorName     "NVIDIA Corporation"
        BoardName      "NVIDIA GeForce RTX 3090 Ti"
        Option         "TripleBuffer" "On"
      '';
    };

    tailscale = {
      enable = true;
      package = pkgs.tailscale;
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
    bluetooth.enable = true;

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
          # Social
          signal-desktop
          discord
          tdesktop
          element-desktop

          # Streaming
          obs-studio

          # Torrent (I only torrent legal stuff :D)
          qbittorrent

          # Games
          prismlauncher

          # Networking
          # ciscoPacketTracer8

          # Image processing
          imagemagick
          krita

          yt-dlp
          gnome.gnome-disk-utility

          # VM stuff
          virt-manager
          virt-viewer

          # Dev tools
          insomnia
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
          insomnia
          awscli2
          obs-studio
          obsidian
          discord

          _1password-gui
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
      pkgs'.thunderbird
      lxappearance
      pavucontrol
      # libsForQt5.kdeconnect-kde
      darktable

      linuxPackages_6_1.perf
      perf-tools

      wine
      winetricks
      wineWowPackages.stable

      # Essential system tools
      tailscale
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
      chrome-gnome-shell

      libreoffice

      pkgs'.docker-compose

      # Media
      ffmpeg
      vlc

      ventoy-bin
      ventoy-full
      woeusb-ng
      ntfs3g

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
      direnv # no more cluttering global namespaces; now with flakes!
      nix-direnv # nix integration for direnv
      asciinema
      erdtree

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
      gnome-browser-connector

      # Browsers
      firefox
      google-chrome

      qpdf
      libsForQt5.ksshaskpass

      virt-manager
    ];

    pathsToLink = [ "/share/nix-direnv" "/libexec" ];

    sessionVariables = {
      KITTY_CONFIG_DIRECTORY = "/shared/System/dotfiles/config/kitty/";
      KITTY_DISABLE_WAYLAND = "1";
      SSH_ASKPASS_REQUIRE = "prefer";
      # MOZ_ENABLE_WAYLAND = "0";
      # PLASMA_USE_QT_SCALING = "1";
      # QT_SCREEN_SCALE_FACTORS="DisplayPort-0=2;DisplayPort-1=2;DisplayPort-2=2;";
    };
  };

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" "Iosevka" ]; })

    myfonts.berkeley-mono-1009-ligatures
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    steam.enable = true;

    kdeconnect.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    dconf.enable = true;

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
            ${builtins.readFile ../../config/neovim/lsp.lua}
            ${builtins.readFile ../../config/neovim/init.lua}
          EOF

          ${builtins.readFile ../../config/neovim/void.vim}
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

  networking.firewall = {
    enable = true;

    # trace: warning: Strict reverse path filtering breaks Tailscale exit node
    # use and some subnet routing setups
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPorts = [ 22 ];
  };

  system.stateVersion = "23.05";
}
