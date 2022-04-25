{ config, pkgs, ... }: {
  nix = {
    package = pkgs.nix_2_7;

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    binaryCaches = [
      "https://hydra.iohk.io"
      "https://iohk.cachix.org"
      "https://nix-community.cachix.org"
    ];

    binaryCachePublicKeys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  boot.isContainer = true;

  time = {
    timeZone = "Asia/Singapore";

    hardwareClockInLocalTime = true; # Because of Windows 10 *eye roll*
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # List services that you want to enable:
  services = {
    /* emojied = { */
    /*   enable = false; */
    /*   port = "5678"; */
    /*   db_user = "sekun"; */
    /*   db_name = "emojied_db"; */
    /* }; */

    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };

  services.httpd = {
    enable = true;
    adminAddr = "sekun@example.com";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
    isNormalUser = true;
    password = "admin";

    extraGroups =
      [ "wheel" ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      hello
    ];

    variables = {
      TERM = "xterm";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  security = {
    doas = {
      enable = true;

      extraRules = [{
        users = [ "sekun" ];
        persist = true;
        keepEnv = true;
      }];
    };

    sudo.enable = false;
  };

  # Open ports in the firewall.
  networking = {
    hostName = "ni";
    useDHCP = false;
    firewall.allowedTCPPorts = [ 80 ];
  };
}
