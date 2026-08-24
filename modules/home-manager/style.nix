{ config, pkgs, ... }: {
  stylix = {
    enable = true;
    image = ../../wallpapers/jupiter.jpg;

    base16Scheme = "${config.stylix.inputs.tinted-schemes}/base16/ayu-dark.yaml";

    fonts = {
      sansSerif = {
        package = pkgs.adwaita-fonts;
        name = "Adwaita Sans";
      };

      monospace = {
        package = pkgs.adwaita-fonts;
        name = "Adwaita Mono";
      };
    };

    icons = {
      enable = true;
      package = pkgs.morewaita-icon-theme;
      light = "MoreWaita";
      dark = "MoreWaita";
    };

    polarity = "dark";

    targets = {
      gnome = {
        image.enable = true;
        fonts.enable = true;
        colors.enable = true;
      };

      firefox = {
        enable = true;
        profileNames = [ "sekun" ];
        firefoxGnomeTheme.enable = true;
        colors.enable = true;
        fonts.enable = true;
      };
    };

    cursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };
}
