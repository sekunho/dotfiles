{ pkgs, ... }: {
  programs.firefox = {
    enable = true;
    profiles.sekun = {
      isDefault = true;
      extensions = {
        force = true;
        packages = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          sponsorblock
          # TODO: Figure out why the heck nix doesn't allow this one even if I
          # have allowUnfree already enabled in `pkgs` :) :) :)
          # control-panel-for-youtube
          bitwarden
          old-reddit-redirect
          duckduckgo-privacy-essentials
          clearurls
        ];
      };

      # https://nix-community.github.io/home-manager/options/home-manager/programs/firefox.html#opt-programs.firefox.profiles._name_.extensions.packages
      # https://github.com/nix-community/home-manager/issues/6398
      settings = {
        "browser.startup.homepage" = "https://duckduckgo.com";
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1;
        "extensions.autoDisableScopes" = 0;
        "sidebar.verticalTabs" = true;
      };

      search = {
        default = "ddg";
        force = true;

        engines = {
          nix-packages = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }
            ];

            definedAliases = [ "@np" ];
          };

          nixos-options = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  { name = "type"; value = "options"; }
                  { name = "channel"; value = "26.05"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }
            ];

            definedAliases = [ "@no" ];
          };

          home-manager-options = {
            urls = [
              {
                template = "https://search.nixos.org/options";
                params = [
                  { name = "type"; value = "options"; }
                  { name = "channel"; value = "26.05"; }
                  { name = "query"; value = "{searchTerms}"; }
                  { name = "source"; value = "home_manager"; }
                ];
              }
            ];

            definedAliases = [ "@hmo" ];
          };

          github-repos = {
            urls = [
              {
                template = "https://github.com/search";
                params = [
                  { name = "type"; value = "repositories"; }
                  { name = "q"; value = "{searchTerms}"; }
                  { name = "utf8"; value = "%E2%9C%93"; }
                ];
              }
            ];

            definedAliases = [ "@gh" ];
          };
        };
      };
    };
  };
}
