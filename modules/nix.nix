{ nix, ... }: {
  nix = {
    # package = nix;

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings.trusted-public-keys = [
      # "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      # "iohk.cachix.org-1:DpRUyj7h7V830dp/i6Nti+NEO2/nhblbov/8MW7Rqoo="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    settings.substituters = [
      # "https://cache.iog.io"
      # "https://iohk.cachix.org"
      "https://nix-community.cachix.org"
    ];
  };
}
