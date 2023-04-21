{
  description = "Sekun's system(s) lmao lol pee";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    emojiedpkg.url = "github:sekunho/emojied";
    oshismashpkg.url = "github:sekunho/oshismash";
    sekunpkg.url = "github:sekunho/sekun.dev";
    agenix.url = "github:ryantm/agenix";

    # Private flakes
    fontpkgs = {
      url = "git+ssh://git@github.com/sekunho/fonts";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    dotfiles-private = {
      url = "git+ssh://git@github.com/sekunho/dotfiles-private";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = {
    self,
    nixpkgs-stable,
    nixpkgs-unstable,
    emojiedpkg,
    oshismashpkg,
    sekunpkg,
    agenix,
    fontpkgs,
    dotfiles-private,
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

      pkgsOverlay = final: prev: {
        agenix = agenix.defaultPackage.${system};

        papermc = import ./packages/papermc.nix {
          inherit lib;
          inherit (pkgs) stdenv fetchurl bash;
          jre = pkgs.jre_headless;
        };
      };

      pkgs = mkPkgs nixpkgs-stable [ pkgsOverlay ];
      pkgs' = mkPkgs nixpkgs-unstable [];
      fonts = fontpkgs.packages.${system};
      emojied = emojiedpkg.packages.${system}.emojied;
      oshismash = oshismashpkg.packages.${system}.oshismash;
      blog = sekunpkg.packages.${system}.blog;
      agenixPackage = agenix.defaultPackage.${system};
      nix = pkgs.nixVersions.nix_2_13;

      publicKeys = {
        arceus.sekun = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINI269n68/pDDfMjkPaWeRUldzr1I/dWfUZl7sZPktwCAAAABHNzaDo= software@sekun.net";
      };
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
            agenix.nixosModules.age

            ./hosts/arceus/configuration.nix
            ./config/nix.nix
          ];

          specialArgs = {
            inherit pkgs;
            inherit pkgs';
            inherit fonts;
            inherit agenixPackage;
            inherit nix;
          };
        };

        giratina = lib.nixosSystem {
          inherit system;

          modules = [
            agenix.nixosModules.age

            ./config/nix.nix
            ./hosts/giratina/configuration.nix
            ./services/tailscale.nix
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
            agenix.nixosModules.age

            ./config/nix.nix
            ./hosts/mew/configuration.nix
            ./services/fail2ban.nix
            ./services/tailscale.nix
          ];

          specialArgs = {
            inherit (pkgs) tailscale jq;
            inherit pkgs;
            inherit pkgs';
            inherit emojied;
            inherit oshismash;
            inherit blog;
            inherit nix;
            agenix = agenixPackage;
          };
        };

        roserade = lib.nixosSystem {
          inherit system;

          modules = [
            ./config/nix.nix
            ./hosts/roserade/configuration.nix
            ./services/fail2ban.nix
            ./services/tailscale.nix

            agenix.nixosModules.age
          ];

          specialArgs = {
            inherit (pkgs) tailscale jq;
            inherit pkgs;
            inherit nix;
            inherit publicKeys;
          };
        };

        lucario = lib.nixosSystem {
          inherit system;

          modules = [
            dotfiles-private.nixosModules.lucario
            agenix.nixosModules.age
            ./services/fail2ban.nix
            ./services/tailscale.nix
            ./config/nix.nix
          ];

          specialArgs = {
            inherit (pkgs) tailscale jq;
            inherit pkgs;
            inherit publicKeys;
            inherit nix;
          };
        };
      };
    };
}
