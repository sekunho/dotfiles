{ self, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ 
    neovim 
  ];

  nix.settings.experimental-features = "nix-command flakes";

  programs = {
    zsh.enable = true;
  };

  services = {
    nix-daemon.enable = true;
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 4;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
