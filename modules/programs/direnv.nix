{ ... }: {
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
}
