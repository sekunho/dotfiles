{ pkgs, ... }: {
  home.username = "sekun";
  home.homeDirectory = "/home/sekun";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    shotcut
  ];

  _module.args = {
    swayConfigPath = "/home/sekun/Projects/dotfiles/config/sway";
    neovimConfigPath = "/home/sekun/Projects/dotfiles/config/neovim";
  };
}
