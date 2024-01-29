{ self, pkgs, pkgs', ... }:
let
  userConfig = { pkgs, ... }: {
    home.stateVersion = "23.11";

    programs = {
      direnv.enable = true;
      direnv.enableZshIntegration = true;
      direnv.nix-direnv.enable = true;

      zsh = {
        enable = true;
        enableAutosuggestions = true;
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
        package = pkgs.neovim-unwrapped;

        # https://github.com/NixOS/nixpkgs/pull/124785#issuecomment-850837745
        plugins = with pkgs.vimPlugins; [
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

        extraConfig = ''
          " Has a leading backslash cause vim will think of it as a normal
          " string. Also, not a fan of the forwardslash for the leader key.
          let mapleader = "\<Space>"

          lua << EOF
            ${builtins.readFile ../../config/neovim/lsp.lua}
            ${builtins.readFile ../../config/neovim/init.lua}
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
  ];

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      myfonts.berkeley-mono-1009-ligatures
      comic-mono
    ];
  };

  nix.settings.experimental-features = "nix-command flakes";

  users.users = {
    sekun = {
      name = "sekun";
      home = "/Users/sekun";
    };

    noodle = {
      name = "noodle";
      home = "/Users/noodle";
    };
  };

  programs = { zsh.enable = true; };
  nix.package = pkgs'.nixVersions.nix_2_18;

  home-manager.users = {
    sekun = userConfig;
    noodle = userConfig;
  };

  networking.hostName = "blaziken";

  services = {
    nix-daemon.enable = true;
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 4;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
