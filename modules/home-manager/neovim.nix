{ config, pkgs, neovimConfigPath, ... }:
let
  nvim-treesitter' = pkgs.vimPlugins.nvim-treesitter.withPlugins (
    plugins: with plugins; [
      # This one is too slow for my taste. :(
      # But I don't have anything else. Not a fan of `vim-elixir`.
      tree-sitter-elixir
      tree-sitter-typescript
      tree-sitter-javascript
      tree-sitter-html
      tree-sitter-css

      tree-sitter-rust
      tree-sitter-haskell
      tree-sitter-lua
      tree-sitter-nix
      tree-sitter-c

      # Shell
      tree-sitter-fish
      tree-sitter-bash

      tree-sitter-make
      tree-sitter-just
    ]
  );
in
{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    sideloadInitLua = true;
    waylandSupport = true;

    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-airline-themes
      vim-airline-clock

      direnv-vim
      nvim-treesitter'

      plenary-nvim
      telescope-nvim
      direnv-vim

      nvim-autopairs
      trouble-nvim
      vim-commentary
      vim-surround
      which-key-nvim

      todo-comments-nvim
    ];
  };

  home.file.neovim = {
    enable = true;
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink neovimConfigPath;
    target = ".config/nvim";
    recursive = true;
  };
}
