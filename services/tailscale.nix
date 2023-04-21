{ config, tailscale, jq, ... }: {
  services.tailscale = {
    enable = true;
    package = tailscale;
  };

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connect to Tailscale";

    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";

    script = ''
      sleep 2

      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"

      if [ $status = "Running" ]; then
        exit 0
      fi

      tailscale_key=$(cat ${config.age.secrets.tailscale_key.path})

      ${tailscale}/bin/tailscale up -authkey $tailscale_key
    '';
  };
}
