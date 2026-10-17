{ self, pkgs, pkgs', ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    cowsay
    ripgrep
    fzf
    hyfetch
    pkgs'.tailscale
    # qbittorrent
    exiftool
    kopia

    musescore

    home-manager
  ];

  fonts = {
    packages = with pkgs; [
      myfonts.berkeley-mono-1009-ligatures
      comic-mono
      atkinson-hyperlegible
    ];
  };


  nix = {
    enable = true;

    settings = {
      experimental-features = "nix-command flakes";

      connect-timeout = 5;
      download-attempts = 2;
      fallback = true;
    };
  };

  users.users = {
    sekun = {
      name = "sekun";
      home = "/Users/sekun";
    };

    noodle = {
      name = "noodle";
      home = "/Users/noodle";
    };
  };

  programs = {
    zsh.enable = true;
    zsh.enableGlobalCompInit = false;
  };

  networking.hostName = "blaziken";

  services = {
    tailscale = {
      enable = true;
      package = pkgs'.tailscale;
    };
  };

  homebrew.enable = true;

  system.primaryUser = "sekun";
  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 4;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
