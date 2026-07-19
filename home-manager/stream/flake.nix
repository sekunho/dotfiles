{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    dotfiles.url = "git+https://forgejo.quoll-owl.ts.net/sekun/dotfiles";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, dotfiles, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations.stream = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [
          ./home.nix
          dotfiles.nixosModules.sway
          dotfiles.nixosModules.emacs
          dotfiles.nixosModules.firefox
        ];

        extraSpecialArgs = {
          swayConfigPath = "/home/stream/.config/home-manager/config/sway";
        };
      };
    };
}
