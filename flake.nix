{
  description = "Sekun's system(s) lmao lol pee";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-21.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs-stable, nixpkgs-unstable, neovim-overlay }:
    let
      system = "x86_64-linux";

      # https://github.com/hlissner/dotfiles/blob/master/flake.nix
      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = extraOverlays;
      };

      pkgs = mkPkgs nixpkgs-stable [ neovim-overlay.overlay ];
      pkgs' = mkPkgs nixpkgs-unstable [];
    in {
      nixosConfigurations = {
        # TODO: Add usual config for Linode/DO/Hetzner/etc.

        # Personal computer
        nixos = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./configuration.nix
          ];

          specialArgs = {
            inherit pkgs;
            inherit pkgs';
          };
        };
      };
    };
}
