{ modulesPath, lib, config, pkgs, pkgs', blog, agenix, ... }: {
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];

  age = {
    secrets = {
      emojiedDBPassword.file = "/root/secrets/emojiedDBPassword.age";
      emojiedDBCACert.file = "/root/secrets/emojiedDBCACert.age";
      tailscale_key.file = "/root/secrets/ts_key__mew.age";
    };

    identityPaths = [ "/root/.ssh/id_mew_root" ];
  };

  programs.ssh = {
    startAgent = true;

    extraConfig = ''
      AddKeysToAgent yes
    '';
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINI269n68/pDDfMjkPaWeRUldzr1I/dWfUZl7sZPktwCAAAABHNzaDo= software@sekun.net"
  ];

  # List services that you want to enable:
  services = {
    emojied = {
      enable = true;
      port = "3000";
      dbHost = "private-db-postgresql-sgp1-27177-do-user-9304792-0.b.db.ondigitalocean.com";
      dbName = "defaultdb";
      dbPort = "25060";
      dbUser = "doadmin";
      dbPoolSize = "5";
      dbPasswordFile = config.age.secrets.emojiedDBPassword.path;
      dbCACertFile = config.age.secrets.emojiedDBCACert.path;
    };

    oshismash = {
      enable = true;
      host = "oshismash.com";
      port = "3001";
      dbHost = "private-db-postgresql-sgp1-27177-do-user-9304792-0.b.db.ondigitalocean.com";
      dbName = "oshismash-db";
      dbPort = "25060";
      dbUser = "doadmin";
      dbPoolSize = "5";
      dbPasswordFile = config.age.secrets.emojiedDBPassword.path;
      dbCACertFile = config.age.secrets.emojiedDBCACert.path;
    };

    openssh = {
      enable = true;
      permitRootLogin = "prohibit-password";
      passwordAuthentication = false;
    };

    caddy = {
      enable = true;
      email = "acme@sekun.net";

      # FIXME: https://caddy.community/t/infinite-redirection/3230/5
      # globalConfig = ''
      #   auto_https disable_redirects
      # '';

      extraConfig = ''
        www.emojied.net, emojied.net {
          reverse_proxy :3000
        }

        www.oshismash.com, oshismash.com {
          reverse_proxy :3001
        }

        blog.sekun.dev {
          redir https://blog.sekun.net{uri} permanent
        }

        blog.sekun.net {
          root * ${blog}
          file_server
        }

        api.sekun.net {
          reverse_proxy arceus:53333
        }
      '';
    };
  };

  networking = {
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      allowedTCPPorts = [ 22 80 443 ];
      checkReversePath = "loose";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = [
      agenix
    ];

    loginShellInit = ''
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    '';
  };

  system.stateVersion = "22.11"; # Did you read the comment?
}
