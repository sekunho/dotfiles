# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  oldUnstable = "29d1f6e1f625d246dcf84a78ef97b4da3cafc6ea";
  newUnstable = "22dc22f8cedc58fcb11afe1acb08e9999e78be9c";

  unstable = import (builtins.fetchTarball
    "https://github.com/nixos/nixpkgs/tarball/${newUnstable}") {
      config = config.nixpkgs.config;
    };
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      (import (builtins.fetchTarball {
        url =
          "https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz";
      }))

      (self: super: {
        nix-direnv = super.nix-direnv.override { enableFlakes = true; };
      })
    ];
  };

  nix = {
    # Enable nix 2.4 for flakes
    package = pkgs.nix_2_4;

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

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.kernelModules = [ "amdgpu" ];
  };

  time = {
    timeZone = "Asia/Singapore";

    hardwareClockInLocalTime = true; # Because of Windows 10 *eye roll*
  };

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking = {
    # Define your hostname.
    hostName = "nixos";
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
      [ "wheel" "networkmanager" "docker" ]; # Enable ‘sudo’ for the user.
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
      unstable.nix-direnv # nix integration for direnv
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

      # Networking
      # ciscoPacketTracer8

      imagemagick

      # Video editing
      openshot-qt

      # Streaming
      unstable.obs-studio

      # Plz no spy
      zoom-us

      # Misc.
      hledger
      hledger-web
      hledger-ui
      wiki-tui
      transmission-gtk
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
      package = pkgs.neovim-nightly;

      # https://github.com/NixOS/nixpkgs/pull/124785#issuecomment-850837745
      configure = {
        packages.myVimPackage = with pkgs.vimPlugins; {
          start = [
            # Airline
            unstable.vimPlugins.vim-airline
            vim-airline-themes
            vim-airline-clock

            # Themes
            gruvbox-nvim

            # Languages, etc.
            direnv-vim
            unstable.vimPlugins.nvim-lspconfig

            # Usage
            # https://nixos.org/manual/nixpkgs/unstable/#vim
            #
            # Available parsers
            # https://tree-sitter.github.io/tree-sitter/#available-parsers
            (unstable.vimPlugins.nvim-treesitter.withPlugins (
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

            # I don't know how to categorize this
            unstable.vimPlugins.plenary-nvim
            unstable.vimPlugins.telescope-nvim
            unstable.vimPlugins.nvim-web-devicons

            # Magit is unfortunately still king :(
            unstable.vimPlugins.vim-fugitive
            unstable.vimPlugins.gitsigns-nvim
          ];
        };

        customRC = ''
          lua << EOF
            -- Mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            local opts = { noremap=true, silent=true }
            vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
            vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
            vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
            vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

            -- Use an on_attach function to only map the following keys
            -- after the language server attaches to the current buffer
            local on_attach = function(client, bufnr)
              -- Enable completion triggered by <c-x><c-o>
              vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

              -- Mappings.
              -- See `:help vim.lsp.*` for documentation on any of the below functions
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
            end

            -- Language Server Protocols
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

            require'lspconfig'.hls.setup {
              on_attach = on_attach,
              settings = {
                haskell = {
                  formattingProvider = "stylish-haskell"
                }
              }
            }

            require'lspconfig'.elixirls.setup {
              on_attach = on_attach,
              cmd = { "elixir-ls" }
            }

            require'lspconfig'.rls.setup{
              on_attach = on_attach
            }

            -- Tree Sitter

            require'nvim-treesitter.configs'.setup {
              highlight = {
                enable = true,
                -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                -- Using this option may slow down your editor, and you may see some duplicate highlights.
                -- Instead of true it can also be a list of languages
                additional_vim_regex_highlighting = true,
              },
            }

            require'nvim-web-devicons'.setup {}

            print("Good day, Sek Un.")
          EOF

          set mouse=a
          syntax on
          set number relativenumber
          set hidden
          set title
          set encoding=utf-8

          " Indents
          set smartindent
          set tabstop=2
          set expandtab
          set shiftwidth=2

          " Themes
          set termguicolors
          set background=dark
          colorscheme gruvbox

          " I'm tired of dealing with separate yanks/pastes
          set clipboard+=unnamedplus

          " <leader>, by default is the backslash key.
          " So to find_files, be in normal mode, and type:
          " \ff
          nnoremap <leader>ff <cmd>Telescope find_files<cr>
          nnoremap <leader>fg <cmd>Telescope live_grep<cr>
          nnoremap <leader>fb <cmd>Telescope buffers<cr>
          nnoremap <leader>fh <cmd>Telescope help_tags<cr>
          nnoremap <leader>fm <cmd>Telescope man_pages<cr>

          set colorcolumn=80

          tnoremap <esc> <C-\><C-N>

          set list
          set listchars=lead:·,trail:·,tab:>-

          let g:airline_theme='base16_gruvbox_dark_medium'

          " To hide the statusline
          set noshowmode

          nmap <esc> :noh <CR>

          autocmd BufWritePre * :%s/\s\+$//e
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
