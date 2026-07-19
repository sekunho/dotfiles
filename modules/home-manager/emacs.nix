{ pkgs, ... }: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;

    # extraPackages = epkgs: [
    #   epkgs.nix-mode
    #   epkgs.nixpkgs-fmt
    # ];
  };

  services.emacs = {
    enable = true;
  };
}
