.PHONY: update-stable
update-stable:
	@echo "updating flake's nixpkgs-stable input"
	nix flake lock --update-input nixpkgs-stable

.PHONY: update-unstable
update-unstable:
	@echo "updating flake's nixpkgs-unstable input"
	nix flake lock --update-input nixpkgs-unstable

.PHONY: switch-arceus
switch-arceus:
	@echo "building and applying arceus configuration"
	doas nixos-rebuild switch --flake .#arceus

.PHONY: switch-mew
switch-mew:
	@echo "building and applying mew configuration"
	doas nixos-rebuild switch --flake .#mew --fast --target-host root@mew

.PHONY: switch-lucario
switch-lucario:
	@echo "building and applying lucario configuration"
	doas nixos-rebuild switch --flake .#lucario --fast --target-host root@lucario

.PHONY: switch-roserade
switch-roserade:
	@echo "building and applying roserade configuration"
	doas nixos-rebuild switch --flake .#roserade --fast --target-host root@roserade
