{ pkgs, ... }: {
  programs = {
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

            # Languages, etc.
            direnv-vim
            # nvim-lspconfig
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
}
