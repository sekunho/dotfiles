update +INPUTS:
  #!/bin/sh
  for input in {{ INPUTS }}; do
    nix flake lock --update-input $input
  done

# Build and switch one or more hosts' configurations
switch CONFIG +HOSTS:
  #!/bin/sh
  for host in {{ HOSTS }}; do
    nixos-rebuild switch --flake .#{{ CONFIG }} \
      --target-host root@$host --use-remote-sudo
  done

switch-local CONFIG:
  doas nixos-rebuild switch --flake .#{{ CONFIG }}
