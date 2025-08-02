{
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixos-22-11.url = "github:NixOS/nixpkgs/nixos-22.11";
    infra.url = "github:sekunho/infra";

    emojiedpkg.url = "github:sekunho/emojied";
    sekunpkg.url = "github:sekunho/sekun.dev";
    agenix.url = "github:ryantm/agenix";
    gnawex.url = "github:gnawex/gnawex";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";

    # Private flakes
    fontpkgs = {
      url = "git+ssh://git@github.com/sekunho/fonts";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    dotfiles-private = {
      url = "git+ssh://git@github.com/sekunho/dotfiles-private";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs =
    { self
    , nixpkgs-stable
    , nixpkgs-unstable
    , nixos-22-11
    , infra
    , emojiedpkg
    , sekunpkg
    , agenix
    , nix-darwin
    , home-manager
    , gnawex
    , fontpkgs
    , dotfiles-private
    , nixos-generators
    }:
    let
      lib = nixpkgs-stable.lib;

      system = {
        x86_64-linux = "x86_64-linux";
        aarch64-darwin = "aarch64-darwin";
      };

      # Thank you https://github.com/hlissner/dotfiles/blob/master/flake.nix
      mkPkgs = system: pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = extraOverlays;
      };

      pkgsOverlay = system: final: prev: {
        agenix = agenix.packages.${system}.default;
        myfonts = fontpkgs.packages.${system};
        emojied = emojiedpkg.packages.${system}.emojied;
        blog = sekunpkg.packages.${system}.blog;
      };

      pkgs-22-11 = mkPkgs nixos-22-11 [ ];
      gnawexpkgs = gnawex.packages.${system};

      publicKeys = {
        arceus.sekun = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINI269n68/pDDfMjkPaWeRUldzr1I/dWfUZl7sZPktwCAAAABHNzaDo= software@sekun.net";
        blaziken.sekun = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE07iMNKunyBGdOq61DWKIBQYy77e1sm69lXaFofkmtp software@sekun.net";
      };

      pkgs = system: mkPkgs system nixpkgs-stable [ (pkgsOverlay system) ];
      pkgs' = system: mkPkgs system nixpkgs-unstable [ ];
      nix = system: (pkgs' system).nixVersions.nix_2_18;
    in
    {
      packages = {
        x86_64-linux = {
          gce = nixos-generators.nixosGenerate {
            system = "x86_64-linux";
            format = "gce";

            modules = [
            ];

            specialArgs = {
              inherit publicKeys;
            };
          };
        };

        aarch64-darwin = { };
      };

      devShells = {
        x86_64-linux = {
          default = (pkgs system.x86_64-linux).mkShell {
            buildInputs = with (pkgs system.x86_64-linux); [
              git
              nil
              nixpkgs-fmt
              just
              fzf
            ];
          };
        };

        aarch64-darwin = {
          default = (pkgs system.aarch64-darwin).mkShell {
            buildInputs = with (pkgs system.aarch64-darwin); [
              git
              nil
              nixpkgs-fmt
              just
              fzf
            ];
          };
        };
      };

      darwinConfigurations."blaziken" = nix-darwin.lib.darwinSystem {
        modules = [
          home-manager.darwinModules.default
          ./hosts/blaziken/configuration.nix
        ];

        specialArgs = {
          inherit self;
          pkgs = pkgs "aarch64-darwin";
          pkgs' = pkgs' "aarch64-darwin";
        };
      };

      nixosConfigurations = {
        # TODO: Move these to `hosts`, and move the existing modules to their
        # own `modules` folder. e.g `modules/lucario/`

        arceus = lib.nixosSystem {
          system = system.x86_64-linux;

          modules = [
            infra.nixosModules.nix
            agenix.nixosModules.age
            ./hosts/arceus/configuration.nix
          ];

          specialArgs = {
            trusted-users = [ "root" "sekun" ];
            nix = (nix system.x86_64-linux);
            pkgs = pkgs system.x86_64-linux;
            pkgs' = pkgs' system.x86_64-linux;
          };
        };

        mew = lib.nixosSystem {
          system = system.x86_64-linux;

          modules = [
            emojiedpkg.nixosModules.default
            agenix.nixosModules.age

            ./config/nix.nix
            ./hosts/mew/configuration.nix
            ./services/fail2ban.nix
            ./services/tailscale.nix
          ];

          specialArgs = {
            inherit (pkgs system.x86_64-linux) jq emojied blog;
            inherit (pkgs' system.x86_64-linux) tailscale;
            inherit publicKeys;
            pkgs = pkgs system.x86_64-linux;
            pkgs' = pkgs' system.x86_64-linux;
            nix = nix system.x86_64-linux;
          };
        };

        roserade = lib.nixosSystem {
          system = system.x86_64-linux;

          modules = [
            ./config/nix.nix
            ./hosts/roserade/configuration.nix
            ./services/fail2ban.nix
            ./services/tailscale.nix

            agenix.nixosModules.age
          ];

          specialArgs = {
            inherit (pkgs system.x86_64-linux) jq;
            inherit (pkgs' system.x86_64-linux) tailscale;
            inherit publicKeys;
            pkgs = pkgs system.x86_64-linux;
            nix = nix system.x86_64-linux;
          };
        };

        lucario = lib.nixosSystem {
          system = system.x86_64-linux;

          modules = [
            dotfiles-private.nixosModules.lucario
            agenix.nixosModules.age
            ./services/fail2ban.nix
            ./services/tailscale.nix
            ./config/nix.nix
          ];

          specialArgs = {
            inherit (pkgs system.x86_64-linux) jq;
            inherit (pkgs' system.x86_64-linux) tailscale;
            inherit publicKeys;
            pkgs = pkgs system.x86_64-linux;
            nix = nix system.x86_64-linux;
          };
        };
      };
    };
}
