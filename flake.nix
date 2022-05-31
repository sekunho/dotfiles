{
  description = "Sekun's system(s) lmao lol pee";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    emojiedpkg.url = "github:sekunho/emojied";
    neovim-overlay.url = "github:nix-community/neovim-nightly-overlay";
    /* emacs-overlay.url = "github:nix-community/emacs-overlay"; */
  };

  outputs = {
    self,
    nixpkgs-stable,
    nixpkgs-unstable,
    emojiedpkg,
    neovim-overlay,
    /* emacs-overlay */
  }:
    let
      system = "x86_64-linux";

      # https://github.com/hlissner/dotfiles/blob/master/flake.nix
      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = extraOverlays;
      };

      pkgs = mkPkgs nixpkgs-stable [
        neovim-overlay.overlay
        /* emacs-overlay.overlay */
      ];

      pkgs' = mkPkgs nixpkgs-unstable [];

      emojied = emojiedpkg.packages.${system}.emojied;
    in {
      nixosConfigurations = {
        # TODO: Add usual config for Linode/DO/Hetzner/etc.

        # Personal computer
        # `nixos-rebuild switch --flake .#ichi` or
        # `nixos-rebuild switch --flake .#`
        ichi = nixpkgs-stable.lib.nixosSystem {
          inherit system;

          modules = [
            emojiedpkg.nixosConfigurations.emojied

            # System configuration
            ./hosts/ichi/configuration.nix
          ];

          specialArgs = {
            inherit pkgs;
            inherit pkgs';
            inherit emojied;
          };
        };

        ni = nixpkgs-stable.lib.nixosSystem {
          inherit system;

          modules = [
            emojiedpkg.nixosConfigurations.emojied

            # System configuration
            ./hosts/ni/configuration.nix
          ];

          specialArgs = {
            inherit pkgs;
            inherit emojied;
          };
        };

      };
    };
}
