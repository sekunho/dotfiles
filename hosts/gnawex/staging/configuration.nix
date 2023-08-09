{ modulesPath, pkgs, publicKeys, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/google-compute-image.nix")
  ];

  security.sudo.wheelNeedsPassword = false;
  services.nscd.enableNsncd = false;

  users.users.root.openssh.authorizedKeys.keys = [ publicKeys.arceus.sekun ];

  users.extraUsers.sekun = {
    isNormalUser = true;
    description = "admin user";
    group = "users";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ publicKeys.arceus.sekun ];
  };

  environment.systemPackages = with pkgs; [ htop ];

  networking = {
    firewall = {
      enable = true;
      trustedInterfaces = [];
      allowedUDPPorts = [];
      allowedTCPPorts = [ 22 ];
      checkReversePath = "loose";
    };
  };

  system.stateVersion = "23.05";
}
