{ username, homeDirectory, ... }: {
  imports = [ ./neovim.nix ./kitty.nix ];

  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "26.05";

  targets.darwin = { copyApps.enable = false; linkApps.enable = true; };

  _module.args.neovimConfigPath = "${homeDirectory}/.config/dotfiles/config/neovim";
  _module.args.kittyConfigPath = "${homeDirectory}/.config/dotfiles/config/kitty";

  programs = {
    direnv.enable = true;
    direnv.enableZshIntegration = true;
    direnv.nix-direnv.enable = true;

    zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      completionInit = ''
        autoload -U compinit && compinit -u
      '';

      plugins = [
      ];
    };
  };
}
