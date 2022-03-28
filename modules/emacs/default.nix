{ pkgs, stdenv, username, ... }:
let
  inherit (pkgs) lib stdenv fetchFromGitHub;
  emacsclientWrapped = pkgs.callPackage ./emacsclient.nix { };
in
{
  imports = [
    ./eslint.nix
    ./prettier.nix
  ];

  home-manager.users."${username}" = {
    programs.emacs = {
      enable = true;
      package = pkgs.emacsWithPackagesFromUsePackage {
        config = ./files/core.org;
        alwaysTangle = true;
        package = pkgs.emacsGit.overrideAttrs (oldAttrs: rec {
          patches = oldAttrs.patches ++ [
            ./patches/no-frame-refocus-cocoa.patch

            # GNU Emacs's main role is an AXTextField instead of AXWindow, it has to be fixed manually.
            # The patches is borrowed from https://github.com/d12frosted/homebrew-emacs-plus/blob/f3c16d68bbf52c1779be279579d124d726f0d04a/patches/emacs-28/
            ./patches/fix-window-role.patch

            ./patches/system-appearance.patch
          ];
        });
      };
    };

    xdg.configFile."emacs/site-lisp/".source = ./files/site-lisp;
    xdg.configFile."emacs/snippets/".source = ./files/snippets;

    xdg.configFile."emacs/init.el".source = ./files/init.el;
    xdg.configFile."emacs/init.el".onChange = ''
      rm -f ~/.config/emacs/init.elc
    '';

    xdg.configFile."emacs/core.org".source = ./files/core.org;
    xdg.configFile."emacs/core.org".onChange = ''
      rm -f ~/.config/emacs/core.{el,elc}
    '';


    home.packages = with pkgs; [
      emacsclientWrapped

      # required by flyspell
      aspell
      aspellDicts.en
      aspellDicts.en-computers
      aspellDicts.en-science

      # misc
      shellcheck
      nixpkgs-fmt
      pgformatter

      ripgrep
      editorconfig-core-c
      ledger
    ];

    programs.bash.initExtra = ''
      ## EMACS ##
      export ALTERNATE_EDITOR=
      export EDITOR=${emacsclientWrapped}/bin/ec
      export VISUAL=${emacsclientWrapped}/bin/ec
    '';

    programs.bash.shellAliases = {
      ",emacs-reset" = ''skhd -r; pkill -f emacs'';
    };
  };
}
