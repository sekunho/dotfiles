{
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-22-11.url = "github:NixOS/nixpkgs/nixos-22.11";

    emojiedpkg.url = "github:sekunho/emojied";
    oshismashpkg.url = "github:sekunho/oshismash";
    sekunpkg.url = "github:sekunho/sekun.dev";
    agenix.url = "github:ryantm/agenix";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

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

  outputs =
    { self
    , nixpkgs-stable
    , nixpkgs-unstable
    , nixos-22-11
    , emojiedpkg
    , oshismashpkg
    , sekunpkg
    , agenix
    , flake-utils
    , nix-darwin
    , home-manager
    , fontpkgs
    , dotfiles-private
    ,
    }:
    let
      system = "aarch64-darwin";
      lib = nixpkgs-stable.lib;

      # Thank you https://github.com/hlissner/dotfiles/blob/master/flake.nix
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

        myfonts = fontpkgs.packages.${system};
        emojied = emojiedpkg.packages.${system}.emojied;
        oshismash = oshismashpkg.packages.${system}.oshismash;
        blog = sekunpkg.packages.${system}.blog;
      };

      pkgs = mkPkgs nixpkgs-stable [ pkgsOverlay ];
      pkgs' = mkPkgs nixpkgs-unstable [ ];
      pkgs-22-11 = mkPkgs nixos-22-11 [ ];
      nix = pkgs.nixVersions.nix_2_13;

      publicKeys = {
        arceus.sekun = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINI269n68/pDDfMjkPaWeRUldzr1I/dWfUZl7sZPktwCAAAABHNzaDo= software@sekun.net";
        blaziken.sekun = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE07iMNKunyBGdOq61DWKIBQYy77e1sm69lXaFofkmtp software@sekun.net";
      };
    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [ nil nixpkgs-fmt just fzf ];
        };
      };

      darwinConfigurations."blaziken" = nix-darwin.lib.darwinSystem {
        modules = [
          home-manager.darwinModules.default
          ./hosts/blaziken/configuration.nix
        ];

        specialArgs = {
          inherit self;
          pkgs = nixpkgs-stable.legacyPackages."aarch64-darwin";
          inherit pkgs';
        };
      };

      darwinPackages = self.darwinConfigurations."blaziken".pkgs;

      nixosConfigurations = {
        # TODO: Move these to `hosts`, and move the existing modules to their
        # own `modules` folder. e.g `modules/lucario/`

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
            inherit nix;
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
            inherit (pkgs) jq emojied oshismash blog;
            inherit (pkgs') tailscale;
            inherit pkgs;
            inherit pkgs';
            inherit nix;
            inherit publicKeys;
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
            inherit (pkgs) jq;
            inherit (pkgs') tailscale;
            inherit pkgs;
            inherit nix;
            inherit publicKeys;
          };
        };

        gnawex-staging = lib.nixosSystem {
          inherit system;

          modules = [
            ./hosts/gnawex/staging/configuration.nix
            ./config/nix.nix
            ./services/fail2ban.nix
          ];

          specialArgs = {
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
            inherit (pkgs) jq;
            inherit (pkgs') tailscale;
            inherit pkgs;
            inherit publicKeys;
            inherit nix;
          };
        };
      };
    };
    }
