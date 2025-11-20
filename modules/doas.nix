{ ... }: {
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
}
