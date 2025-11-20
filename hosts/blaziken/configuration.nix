{ self, pkgs, pkgs', ... }:
let
  userConfig = { pkgs, ... }: {
    home.stateVersion = "25.05";

    programs = {
      direnv.enable = true;
      direnv.enableZshIntegration = true;
      direnv.nix-direnv.enable = true;

      zsh = {
        enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;

        plugins = [
        ];
      };
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    neovim
    cowsay
    ripgrep
    fzf
    neofetch
    pkgs'.tailscale
    # qbittorrent
    exiftool
    kopia
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
    package = pkgs'.nixVersions.nix_2_28;
    settings.experimental-features = "nix-command flakes";

    settings = {
      trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];

      substituters = [
        "https://cache.iog.io"
      ];
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

    editor = {
      name = "editor";
      home = "/Users/editor";
    };
  };

  programs = { zsh.enable = true; };

  home-manager.users = {
    sekun = userConfig;
    noodle = userConfig;
    editor = userConfig;
  };

  networking.hostName = "blaziken";

  services = {
    tailscale = {
      enable = true;
      package = pkgs'.tailscale;
    };
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 4;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
