{ modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/google-compute-image.nix")
  ];

  security.sudo.wheelNeedsPassword = false;
  services.nscd.enableNsncd = false;

  users.users.root.openssh.authorizedKeys.keys = [ "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINI269n68/pDDfMjkPaWeRUldzr1I/dWfUZl7sZPktwCAAAABHNzaDo= software@sekun.net" ];

  users.extraUsers.sekun = {
    isNormalUser = true;
    description = "admin user";
    group = "users";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINI269n68/pDDfMjkPaWeRUldzr1I/dWfUZl7sZPktwCAAAABHNzaDo= software@sekun.net" ];
  };

  environment.systemPackages = with pkgs; [ htop ];

  system.stateVersion = "23.05";
}
