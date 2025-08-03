{ self, pkgs, pkgs', ... }:
let
  userConfig = { pkgs, ... }: {
    home.stateVersion = "25.05";

    programs = {
      direnv.enable = true;
      direnv.enableZshIntegration = true;
      direnv.nix-direnv.enable = true;

      zsh = {
        enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;

        plugins = [
        ];
      };

      neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        # https://github.com/NixOS/nixpkgs/issues/137829
        package = pkgs'.neovim-unwrapped;

        # https://github.com/NixOS/nixpkgs/pull/124785#issuecomment-850837745
        plugins = with pkgs'.vimPlugins; [
          # Airline
          vim-airline
          vim-airline-themes
          vim-airline-clock

          # ASCII diagram editor
          venn-nvim

          # Themes
          gruvbox-nvim

          # mini-icons

          # Languages, etc.
          direnv-vim
          ghcid
          catppuccin-nvim
          nvim-web-devicons

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
              tree-sitter-sql

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
          # fidget-nvim

          # I don't know how to categorize this
          # plenary-nvim

          # telescope-nvim
          # telescope-ui-select-nvim
          # null-ls-nvim

          # nvim-web-devicons
          auto-pairs
          # nvim-fzf
          # trouble-nvim
          vim-commentary
          vim-surround
          # which-key-nvim

          # Magit is unfortunately still king :(
          # gitsigns-nvim
        ];

        extraConfig = ''
          " Has a leading backslash cause vim will think of it as a normal
          " string. Also, not a fan of the forwardslash for the leader key.
          let mapleader = "\<Space>"

          lua << EOF
            ${builtins.readFile ../../config/neovim/init.lua}
            ${builtins.readFile ../../config/neovim/lsp.lua}
          EOF

          ${builtins.readFile ../../config/neovim/init.vim}
        '';
      };
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    neovim
    cowsay
    ripgrep
    fzf
    neofetch
    pkgs'.tailscale
    # qbittorrent
    exiftool
    kopia
  ];

  fonts = {
    packages = with pkgs; [
      myfonts.berkeley-mono-1009-ligatures
      comic-mono
      atkinson-hyperlegible
    ];
  };


  nix = {
    enable = true;
    package = pkgs'.nixVersions.nix_2_28;
    settings.experimental-features = "nix-command flakes";

    settings = {
      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];

      substituters = [
        "https://cache.iog.io"
      ];
    };
  };

  users.users = {
    sekun = {
      name = "sekun";
      home = "/Users/sekun";
    };

    noodle = {
      name = "noodle";
      home = "/Users/noodle";
    };

    editor = {
      name = "editor";
      home = "/Users/editor";
    };
  };

  programs = { zsh.enable = true; };

  home-manager.users = {
    sekun = userConfig;
    noodle = userConfig;
    editor = userConfig;
  };

  networking.hostName = "blaziken";

  services = {
    tailscale = {
      enable = true;
      package = pkgs'.tailscale;
    };
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 4;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
