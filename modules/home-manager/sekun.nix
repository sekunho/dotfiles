{ ... }: {
  imports = [
    ./sway.nix
  ];

  # 1. Programs
  # 2. DE/WM
  # 3. Pipewire/audio
  # 4. Fonts
  # 5. Emacs
  home.username = "sekun";
  home.homeDirectory = "/home/sekun";
  home.stateVersion = "26.05";

  _module.args.swayConfigPath = "/home/sekun/Projects/dotfiles/config/sway";
}
