{ pkgs, ... }: {
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.gnome.core-apps.enable = true;
  services.gnome.core-developer-tools.enable = true;
  services.gnome.games.enable = true;
  environment.gnome.excludePackages = with pkgs; [ gnome-tour gnome-user-docs ];

  programs.dconf.enable = true;

  programs.dconf.profiles.user.databases = [
    {
      settings."org/gnome/desktop/interface".cursor-theme = "Adwaita";
      # settings."org/gnome/desktop/interface".icon-theme = "MoreWaita";
    }
  ];
}
