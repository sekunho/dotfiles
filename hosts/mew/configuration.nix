{ modulesPath, lib, config, pkgs, pkgs', blog, agenixPackage, ... }: {
  imports = lib.optional (builtins.pathExists ./do-userdata.nix) ./do-userdata.nix ++ [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
  ];

  age = {
    secrets = {
      emojiedDBPassword.file = "/root/secrets/emojiedDBPassword.age";
      emojiedDBCACert.file = "/root/secrets/emojiedDBCACert.age";
      tailscaleKey.file = "/root/secrets/tailscaleKey.age";
    };

    identityPaths = [ "/root/.ssh/id_mew_root" ];
  };

  programs.ssh = {
    startAgent = true;

    extraConfig = ''
      AddKeysToAgent yes
    '';
  };

  nix = {
    package = pkgs.nixVersions.nix_2_11;

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings.trusted-public-keys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    settings.substituters = [
      "https://cache.iog.io"
      "https://iohk.cachix.org"
      "https://nix-community.cachix.org"
    ];
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCnYwiKU31DCJCG9mAFJ72AhBVb/jfMVJm9UODTsPvVmtdsApnEnYanUboH1mM+z0W0XCEUWSHlRzqkFoTj2fOejalsBwALjKP8Bx+18SUIn5uEoy9FI9sjs/6vHx8Xt32fUhNU3r/inttFemRhpwodWooK537FbXqypt3dOcDbHr8anNO5xvdB+oscbPjHRJnp9j9iVsag31mynnSQe0yyIYooNTe77+0ZsxbgBtrooukEpLyOpdhL4iP7oWsXdb4xFM2xDlhD4MEdjblnom5ZmKKPssSuBV0HYnlOGmqjvXUj0xn+BlvbQiiTcTK14/KgldB+T5gc4R22s6VodTV0I6rTvdosudOTT4hHQecx9U2xN4xki27ygkGRcTJmrghShvE+lzU4ad4lotcKWv9AUGJopKURf8jtoF6AgDVYaQ42NhpVMwf4VW0Md/wWDDWXYh0N/4kRsCZEbRclDksLOuq3TbHP++wsoLfk5YTM0tu/+EDR/Cqdr0uXgaVYAyM= sekun@ichi"
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

    tailscale = {
      enable = true;
      package = pkgs'.tailscale;
    };

    nginx = {
      enable = true;

      # NOTE: Set SRV and A record for using domain
      streamConfig = ''
        upstream arceus-minecraft {
          server arceus:4111;
        }

        server {
          listen 25565;
          proxy_pass arceus-minecraft;
        }
      '';

      virtualHosts."mc.sekun.net" = {
        addSSL = false;
        enableACME = false;

        listen = [
          { addr = "0.0.0.0"; port = 81; }
          { addr = "[::0]"; port = 81; }
        ];
      };
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
      '';
    };
  };

  systemd = {
    services = {
      tailscale-autoconnect = {
        description = "Automatic connect to Tailscale";

        after = [ "network-pre.target" "tailscale.service" ];
        wants = [ "network-pre.target" "tailscale.service" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig.Type = "oneshot";

        script = with pkgs'; ''
          sleep 2

          status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"

          if [ $status = "Running" ]; then
            exit 0
          fi

          tailscale_key=$(cat ${config.age.secrets.tailscaleKey.path})

          ${tailscale}/bin/tailscale up -authkey $tailscale_key
          '';
      };
    };
  };

  networking = {
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      allowedTCPPorts = [ 22 80 443 25565 ];
      checkReversePath = "loose";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [];

    loginShellInit = ''
      export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    '';
  };

  system.stateVersion = "22.11"; # Did you read the comment?
}
