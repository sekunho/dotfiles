{ config, swayConfigPath, ... }: {
  home.file = {
    sway = {
      enable = true;
      force = true;
      source = config.lib.file.mkOutOfStoreSymlink swayConfigPath;
      target = ".config/sway";
      recursive = true;
    };
  };
}
