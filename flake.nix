{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    disko = {
      url = "github:nix-community/disko";
      # inputs.nixpkgs.url = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-22-11.url = "github:NixOS/nixpkgs/nixos-22.11";
    infra.url = "github:sekunho/infra";

    emojiedpkg.url = "github:sekunho/emojied";
    sekunpkg.url = "github:sekunho/sekun.dev";
    agenix.url = "github:ryantm/agenix";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Private flakes
    fontpkgs = {
      url = "git+ssh://git@github.com/sekunho/fonts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles-private = {
      url = "git+ssh://git@github.com/sekunho/dotfiles-private";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm.url = "github:microvm-nix/microvm.nix";
    microvm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-unstable
    , nixos-hardware
    , determinate
    , disko
    , nixos-22-11
    , infra
    , emojiedpkg
    , sekunpkg
    , agenix
    , nix-darwin
    , home-manager
    , fontpkgs
    , dotfiles-private
    , nixos-generators
    , microvm
    }:
    let
      lib = nixpkgs.lib;

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

      publicKeys = {
        arceus.sekun = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINI269n68/pDDfMjkPaWeRUldzr1I/dWfUZl7sZPktwCAAAABHNzaDo= software@sekun.net";
        blaziken.sekun = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE07iMNKunyBGdOq61DWKIBQYy77e1sm69lXaFofkmtp software@sekun.net";
      };

      pkgs = system: mkPkgs system nixpkgs [ (pkgsOverlay system) ];
      pkgs' = system: mkPkgs system nixpkgs-unstable [ ];
      nix = system: (pkgs system).nix;
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
          ./modules/programs/neovim.nix
          ./hosts/blaziken/configuration.nix
        ];

        specialArgs = {
          inherit self;
          pkgs = pkgs "aarch64-darwin";
          pkgs' = pkgs' "aarch64-darwin";
        };
      };

      nixosConfigurations = {
        arceus = lib.nixosSystem {
          system = system.x86_64-linux;

          modules = [
            ./modules/programs/direnv.nix
            ./modules/programs/neovim.nix
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

        litten = nixpkgs.lib.nixosSystem {
          modules = [
            ./modules/doas.nix
            ./modules/programs/git.nix
            ./modules/programs/neovim.nix
            ./modules/programs/fish.nix
            ./modules/programs/direnv.nix
            ./modules/nix.nix
            ./hosts/litten/configuration.nix
            disko.nixosModules.disko
            nixos-hardware.nixosModules.framework-desktop-amd-ai-max-300-series
            determinate.nixosModules.default

            microvm.nixosModules.host {
              networking.hostName = "litten";

              microvm.autostart = [
                "ilex"
              ];
            }
          ];

          specialArgs = {
            pkgs = pkgs system.x86_64-linux;
            nix = nix system.x86_64-linux;
            microvm = microvm.nixosModules;
          };
        };
      };
    };
}
