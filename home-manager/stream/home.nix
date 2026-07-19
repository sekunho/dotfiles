{ config, nixosModules, pkgs, ... }: {
  # 1. Programs
  # 2. DE/WM
  # 3. Pipewire/audio
  # 4. Fonts
  # 5. Emacs
  home = {
    username = "stream";
    homeDirectory = "/home/stream";
    stateVersion = "26.05";

    packages = with pkgs; [
      shotcut
    ];
  };

  _module.args.swayConfigPath = "/home/stream/.config/home-manager";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
