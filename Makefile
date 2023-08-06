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

.PHONY: switch-gnawex-staging
switch-gnawex-staging:
	# NOTE: Need to use torterra DNS to resolve `gx-staging-x.sekun.net`
	@echo "building and applying gnawex-staging configuration"
	doas nixos-rebuild switch --flake .#gnawex-staging --fast --target-host root@gx-staging-1.sekun.net

.PHONY: switch-all
switch-all:
	make switch-arceus
	make switch-mew
	make switch-lucario
	make switch-roserade
