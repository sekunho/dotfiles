{ pkgs, ... }: {
  home.username = "stream";
  home.homeDirectory = "/home/stream";
  home.stateVersion = "26.05";

  home.packages = with pkgs; [
    shotcut
  ];

  _module.args.swayConfigPath = "/home/stream/.config/dotfiles/config/sway";
}
