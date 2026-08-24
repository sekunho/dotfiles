{ pkgs, ... }: {
  sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  environments.systemPackages = with pkgs; [
    swayidle
  ];
}
