{ config, pkgs, publicKeys, ... }: {
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  nixpkgs.config.allowUnfree = true;

  age = {
    secrets = {
      tailscale_key.file = "/root/secrets/ts_key__roserade.age";
      longview_key.file = "/root/secrets/longview_key.age";
    };

    identityPaths = [ "/root/.ssh/id_ed25519" ];
  };

  networking = {
    hostName = "roserade";
    usePredictableInterfaceNames = false;
    useDHCP = false;
    interfaces.eth0.useDHCP = true;

    firewall = {
      enable = true;
      checkReversePath = "loose";
      trustedInterfaces = [ "tailscale0" ];
      allowedUDPPorts = [ config.services.tailscale.port ];
      allowedTCPPorts = [ 22 25565 ];
    };
  };

  nix.settings.trusted-users = [ "root" "@wheel" ];

  environment.systemPackages = with pkgs; [
    inetutils
    mtr
    sysstat
    htop
    agenix
  ];

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [ publicKeys.arceus.sekun ];
    };

    grassknot = {
      isNormalUser = true;
      home = "/home/grassknot";
      description = "Grass Knot";
      extraGroups = [ "wheel" "networkmanager" ];
      openssh.authorizedKeys.keys = [ publicKeys.arceus.sekun ];
    };
  };

  services = {
    longview = {
      enable = true;
      apiKeyFile = config.age.secrets.longview_key.path;
    };

    # NOTE: Cause Linode will complain about the host's time being slow
    ntp = {
      enable = true;

      servers = [
        "0.jp.pool.ntp.org"
        "1.jp.pool.ntp.org"
        "2.jp.pool.ntp.org"
        "3.jp.pool.ntp.org"
      ];
    };

    openssh = {
      enable = true;
      permitRootLogin = "yes";
      passwordAuthentication = false;
    };

    minecraft-server = {
      enable = true;
      eula = true;
      declarative = true;
      package = pkgs.papermc;

      jvmOpts = ''
        -Xms512M
        -Xmx3072M
        -XX:+UseG1GC
        -XX:+ParallelRefProcEnabled
        -XX:MaxGCPauseMillis=200
        -XX:+UnlockExperimentalVMOptions
        -XX:+DisableExplicitGC
        -XX:+AlwaysPreTouch
        -XX:G1NewSizePercent=30
        -XX:G1MaxNewSizePercent=40
        -XX:G1HeapRegionSize=8M
        -XX:G1ReservePercent=20
        -XX:G1HeapWastePercent=5
        -XX:G1MixedGCCountTarget=4
        -XX:InitiatingHeapOccupancyPercent=15
        -XX:G1MixedGCLiveThresholdPercent=90
        -XX:G1RSetUpdatingPauseTimePercent=5
        -XX:SurvivorRatio=32
        -XX:+PerfDisableSharedMem
        -XX:MaxTenuringThreshold=1
        -Dusing.aikars.flags=https://mcflags.emc.gs
        -Daikars.new.flags=true
      '';

      serverProperties = {
        online-mode = false;
        server-port = 25565;
        gamemode = "survival";
        motd = "sekun deez nuts, now 24/7 and with lower ping!";
        max-players = 20;
        difficulty = "hard";
        simulation-distance = 4;
        view-distance = 7;
        network-compression-threshold = 512;
      };
    };
  };

  system.stateVersion = "22.11";
}
