{ modulesPath, pkgs, publicKeys, config, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/google-compute-image.nix")
  ];

  age = {
    secrets = {
      gx-stg-db-password.file = "/root/secrets/gx-stg-db-password.age";
      gx-stg-db-ca-cert.file = "/root/secrets/gx-stg-db-ca-cert.age";
      gx-stg-db-client-cert.file = "/root/secrets/gx-stg-db-client-cert.age";
      gx-stg-db-client-key.file = "/root/secrets/gx-stg-db-client-key.age";
    };

    identityPaths = [ "/root/.ssh/id_ed25519" ];
  };

  security.sudo.wheelNeedsPassword = false;

  services = {
    nscd.enableNsncd = false;

    gnawex = {
      enable = true;
      server_port = "3000";
      server_secret_key = "y2T-YcKjJ9WsntIGRPafygHddsoppeduokao0NZZBXPyUlouchBFNPeOScJ0q-mi-JnyunWL-YK7Uc4Djqp4sw";

      db_host = "10.17.128.3";
      db_name = "gnawex_staging";
      db_port = "5432";
      db_user = "gnawex";
      db_password_file = config.age.secrets.gx-stg-db-password.path;
      db_ca_cert_file = config.age.secrets.gx-stg-db-ca-cert.path;
      db_client_cert_file = config.age.secrets.gx-stg-db-client-cert.path;
      db_client_key_file = config.age.secrets.gx-stg-db-client-key.path;
    };

    caddy = {
      enable = true;
      email = "acme@sekun.net";

      # FIXME: https://caddy.community/t/infinite-redirection/3230/5
      # globalConfig = ''
      #   auto_https disable_redirects
      # '';

      extraConfig = ''
        gnawex.space {
          redir https://www.gnawex.space{uri}
        }

        www.gnawex.space {
          reverse_proxy :3000
        }
      '';
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    publicKeys.arceus.sekun
    publicKeys.blaziken.sekun
  ];

  users.extraUsers.sekun = {
    isNormalUser = true;
    description = "admin user";
    group = "users";
    extraGroups = [ "wheel" ];

    openssh.authorizedKeys.keys = [
      publicKeys.arceus.sekun
      publicKeys.blaziken.sekun
    ];
  };

  environment.systemPackages = with pkgs; [ htop agenix ];

  networking = {
    firewall = {
      enable = true;
      trustedInterfaces = [ ];
      allowedUDPPorts = [ ];
      allowedTCPPorts = [ 22 80 443 ];
      checkReversePath = "loose";
    };
  };

  system.stateVersion = "23.05";
}
