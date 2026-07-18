{ pkgs, ... }: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;

    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.nixpkgs-fmt
    ];

    extraConfig = ''
      (setq standard-indent 2)
      (tool-bar-mode 0)
    '';
  };

  services.emacs = {
    enable = true;
  };
}
