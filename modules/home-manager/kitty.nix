{ config, pkgs, kittyConfigPath, ... }: {
  home.packages = [ pkgs.kitty ];

  home.file.kitty = {
    enable = true;
    force = true;
    source = config.lib.file.mkOutOfStoreSymlink kittyConfigPath;
    target = ".config/kitty";
    recursive = true;
  };
}
