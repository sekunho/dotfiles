# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, pkgs', ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Services
    # https://nixos.wiki/wiki/NixOS:extend_NixOS
    # ./modules/services/emojied.nix
  ];

  containers = {
    indigo = {
      config = import ../../containers/indigo/configuration.nix;
      ephemeral = true;
      autoStart = true;

      privateNetwork = true;
      localAddress = "10.0.0.2";
      hostAddress = "10.0.0.1";
    };
  };

  nix = {
    package = pkgs.nix_2_7;

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    binaryCaches = [
      "https://hydra.iohk.io"
      "https://iohk.cachix.org"
      "https://nix-community.cachix.org"
    ];

    binaryCachePublicKeys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  /* microvm.vms = { */
  /*   ni = { */
  /*     flake = "path:./hosts/ni"; */
  /*     updateFlake = "microvm"; */
  /*   }; */
  /* }; */

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.kernelModules = [ "amdgpu" "kvm-amd" ];
    kernelPackages = pkgs.linuxPackages_5_15;
  };

  virtualisation.libvirtd.enable = true;

  time = {
    timeZone = "Asia/Singapore";

    hardwareClockInLocalTime = true; # Because of Windows 10 *eye roll*
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    # Define your hostname.
    hostName = "ichi";
    useDHCP = false;

    interfaces = {
      enp34s0.useDHCP = true;
      wlp40s0.useDHCP = true;
    };

    networkmanager.enable = true;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

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
      interactiveShellInit = ''
        direnv hook fish | source
      '';
      shellAliases = { doom = "~/.emacs.d/bin/doom"; };
    };
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # List services that you want to enable:
  services = {
    emojied = {
      enable = true;
      port = "5678";
      db_user = "sekun";
      db_name = "emojied_db";
    };

    redshift.enable = true;

    # Enable the GNOME Desktop Environment.
    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      # Configure keymap in X11
      layout = "us";

      # services.xserver.xkbOptions = "eurosign:e";
      displayManager.gdm = {
        enable = true;
        wayland = false;
      };

      desktopManager.gnome.enable = true;

      videoDrivers = [ "amdgpu" ];
    };

    # For server mode
    emacs.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };

  sound.enable = true;

  hardware = {
    pulseaudio.enable = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      package = pkgs.mesa.drivers;
      package32 = pkgs.pkgsi686Linux.mesa.drivers;
      extraPackages = with pkgs; [ rocm-opencl-icd rocm-opencl-runtime ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sekun = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups =
      [ "wheel" "networkmanager" "docker" "libvirtd" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      # Essential system tools
      htop
      powertop
      neofetch
      doas
      xorg.xeyes
      vulkan-tools
      lshw
      tree
      rclone # Encrypt files and make a remote backup
      glxinfo # View GPU-related information
      radeontop # Monitor GPU usage for AMD

      # Media
      ffmpeg
      youtube-dl
      vlc

      # Disks and whatnot
      ventoy-bin

      # Dev tools
      kitty
      xclip
      wget
      curl
      git
      gnupg # something i need for git that i haven't looked into
      nix-du # i forgot what this was
      graphviz # visualize stuff in graphs
      nixfmt # make nix code look pretty and nice
      cloc # how many spaghetti lines of code have I written already?
      direnv # no more cluttering global namespaces; now with flakes!
      pkgs'.nix-direnv # nix integration for direnv
      asciinema
      wireguard

      # Database
      sqlitebrowser
      dbeaver

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

      # Customization
      gnome.gnome-tweaks

      # Browsers
      firefox
      google-chrome

      # Messaging
      signal-desktop
      element-desktop
      discord
      tdesktop

      # Networking
      # ciscoPacketTracer8

      imagemagick
      krita

      # Video editing
      openshot-qt

      # Streaming
      obs-studio

      # Plz no spy
      zoom-us

      # Misc.
      hledger
      hledger-web
      hledger-ui
      wiki-tui
      transmission-gtk

      # VM stuff
      virt-manager
      virt-viewer

      pkgs'.cloudflared
    ];

    pathsToLink = [ "/share/nix-direnv" ];

    sessionVariables = rec {
      KITTY_CONFIG_DIRECTORY = "\${HOME}/System/dotfiles/config/kitty/";
    };
  };

  fonts.fonts = with pkgs;
    [ (nerdfonts.override { fonts = [ "JetBrainsMono" "Iosevka" ]; }) ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
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
        packages.myVimPackage = with pkgs'.vimPlugins; {
          start = [
            # Airline
            vim-airline
            vim-airline-themes
            vim-airline-clock

            # Themes
            gruvbox-nvim

            # Languages, etc.
            direnv-vim
            nvim-lspconfig

            # Usage
            # https://nixos.org/manual/nixpkgs/unstable/#vim
            #
            # Available parsers
            # https://tree-sitter.github.io/tree-sitter/#available-parsers
            (pkgs'.vimPlugins.nvim-treesitter.withPlugins (
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

            # I don't know how to categorize this
            pkgs'.vimPlugins.plenary-nvim
            pkgs'.vimPlugins.telescope-nvim
            pkgs'.vimPlugins.nvim-web-devicons
            pkgs'.vimPlugins.auto-pairs
            pkgs'.vimPlugins.trouble-nvim
            pkgs'.vimPlugins.vim-commentary
            pkgs'.vimPlugins.vim-surround
            pkgs'.vimPlugins.which-key-nvim

            pkgs'.vimPlugins.rust-vim

            # Magit is unfortunately still king :(
            pkgs'.vimPlugins.gitsigns-nvim
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

  virtualisation.docker.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # PostgreSQL
  services.postgresql = {
    enable = true;
    extraPlugins = with pkgs.postgresql14Packages; [ pgtap ];
    package = pkgs.postgresql_14;
    authentication = pkgs.lib.mkOverride 14 ''
      local all all trust
      host all all ::1/128 trust
      host all all localhost trust
    '';

    initialScript = pkgs.writeText "backend-initScript" ''
    -- Ensure the DB defaults to UTC
    SET timezone TO 'UTC';
    '';

    # https://github.com/adisbladis/nixconfig/blob/0ce9e8f4556da634a12c11b16bce5364b6641a83/hosts/bladis/synapse.nix
    settings = {
      shared_preload_libraries             = "pg_stat_statements";
      session_preload_libraries            = "auto_explain";
      track_io_timing                      = "on";
      track_functions                      = "pl";
      log_duration                         = true;
      log_statement                        = "all";

      # AUTO_EXPLAIN stuff
      "auto_explain.log_min_duration"      = 0;
      "auto_explain.log_analyze"           = true;
      "auto_explain.log_triggers"          = true;
      "auto_explain.log_verbose"           = true;
      "auto_explain.log_nested_statements" = true;
    };
  };

  location = {
    provider = "manual";

    # No, not my actual location. Just using a country with similar enough
    # timezones lol.
    latitude = 1.3521;
    longitude = 103.8198;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
