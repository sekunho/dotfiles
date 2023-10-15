let
  hosts = {
    arceus = {
      sekun = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCUboqku5i0dRaOoTZab2aAtD6WWL5eCPhBQett0bVYYzWupKywA+f/HKy6TBk+syQ9mJ4tf9uBt1bsrpoYIlxzjpVj/iNU+jPxlQJl02Rmryq8dO0DaTh7gTpwZXx4MVUdbI4eV8CZ2tEBYIpPpuPjs8h7014RQJfImrXXo4DBEOTrYZ+GcPR1ITCJHMwMbv4MC+2Qvas67mEfvDAzhFqNR0srOplyRrzmFsNu2XBSjiZVsKjWsG90F21vf+yXfkFHfVILWCYxMumL+CC6rotlKlReMenuMgWhSGBxz2N2P6KifqgIHSMRfp+aVeTwIQTuUSuPFkO4PjNXkgEQvKakOOb/pSruO7fyMWowbVVONg+m+L+SCdrjC4ulxz5VOSdPtY0ZNS29QlwT6lSlCKcCQ4R0RtY+lWsLGUaPApxjqj4gVTEGDFFEx6NUQnhOZcNLDSKtAzIfxWjhLhsyTOVGxH0qTk9a0wbw/NA22eRx3iKLQ4qpF+tj5ow/6h2tywyTiDeXd9MPrOZazy+X8emwRUXvgW1gb6zMmM80/XDc7h/ojfiK5Wg2mkK/L9AksTJeV/EmX5XTNBY5Rl+anXMyh7MnYf9OEX4Ts3hBtdzJWCaQe793E6q14zmZgXP/N4Lj7YawtpFcHk5sw76KYG8tCy7ppexJVYtUA33HXULJnQ== devops@sekun.net
";
    };

    lucario = {
      root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHX+3tKb0OOld/w0In1Ckq5gWKJgfSLMTqAIzXUJtLzG root@lucario";
    };

    gx-stg-1 = {
      root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGRhVj+b2OxbYIi6+tT1MQnlegoTBO1xMqYFYMduFa1O devops@sekun.net
";
    };
  };

  mew = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOq98pf8ZVPTjaLWB7lEFnyqHmVD40KfnTFWZ05xKzC9 sekun@ichi";
in
{
  /* "emojiedDBPassword.age".publicKeys = [ sekun mew ]; */
  /* "emojiedDBCACert.age".publicKeys = [ sekun mew ]; */
  /* "tailscaleKey.age".publicKeys = [ sekun mew ]; */
  "ts_key__hydra.age".publicKeys = with hosts; [ lucario.root gx-stg-1.root ];
  "gx-stg-db-password.age".publicKeys = with hosts; [ gx-stg-1.root ];
  "gx-stg-db-ca-cert.age".publicKeys = with hosts; [ gx-stg-1.root ];
  "gx-stg-db-client-cert.age".publicKeys = with hosts; [ gx-stg-1.root ];
  "gx-stg-db-client-key.age".publicKeys = with hosts; [ gx-stg-1.root ];
}
