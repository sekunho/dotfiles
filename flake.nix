{
  description = "Sekun's system(s) lmao lol pee";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    emojiedpkg.url = "github:sekunho/emojied";
    oshismashpkg.url = "github:sekunho/oshismash";
    sekunpkg.url = "github:sekunho/sekun.dev";
    fontpkgs.url = "git+ssh://git@github.com/sekunho/fonts";
    deploy-rs.url = "github:serokell/deploy-rs";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
    self,
    nixpkgs-stable,
    nixpkgs-unstable,
    emojiedpkg,
    oshismashpkg,
    sekunpkg,
    fontpkgs,
    deploy-rs,
    agenix
  }:
    let
      system = "x86_64-linux";
      lib = nixpkgs-stable.lib;

      # https://github.com/hlissner/dotfiles/blob/master/flake.nix
      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = extraOverlays;
      };

      pkgs = mkPkgs nixpkgs-stable [];
      pkgs' = mkPkgs nixpkgs-unstable [];
      fonts = fontpkgs.packages.${system};
      emojied = emojiedpkg.packages.${system}.emojied;
      oshismash = oshismashpkg.packages.${system}.oshismash;
      blog = sekunpkg.packages.${system}.blog;
      agenixPackage = agenix.defaultPackage.${system};
    in {
      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [ nil nixpkgs-fmt ];
        };
      };

      nixosConfigurations = {
        # TODO: Add usual config for Linode/DO/Hetzner/etc.

        # Personal computer
        # `nixos-rebuild switch --flake .#arceus ` or
        # `nixos-rebuild switch --flake .#`
        arceus = lib.nixosSystem {
          inherit system;

          modules = [
            ./hosts/arceus/configuration.nix
            agenix.nixosModules.age
          ];

          specialArgs = {
            inherit pkgs;
            inherit pkgs';
            inherit fonts;
            inherit agenixPackage;
          };
        };

        giratina = lib.nixosSystem {
          inherit system;

          modules = [
            ./hosts/giratina/configuration.nix
            agenix.nixosModules.age
          ];

          specialArgs = {
            inherit pkgs;
            inherit pkgs';
            inherit agenixPackage;
          };
        };

        mew = lib.nixosSystem {
          inherit system;

          modules = [
            emojiedpkg.nixosModules.default
            oshismashpkg.nixosModule
            ./hosts/mew/configuration.nix
            agenix.nixosModules.age
          ];

          specialArgs = {
            inherit pkgs;
            inherit pkgs';
            inherit emojied;
            inherit oshismash;
            inherit blog;
            inherit agenixPackage;
          };
        };
      };
    };
}
