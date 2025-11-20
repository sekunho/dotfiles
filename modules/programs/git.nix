{ ... }: {
  programs.git = {
    enable = true;
    config.safe.directory = "/home/sekun/dotfiles";
    config.core.editor = "vim";
  };
}
