{ pkgs, stdenv, username, ... }:
let
  inherit (pkgs) lib stdenv fetchFromGitHub;
  emacsclientWrapped = pkgs.callPackage ./emacsclient.nix { };

  tree-sitter-grammars = pkgs.stdenv.mkDerivation rec {
    name = "tree-sitter-grammars";
    version = "0.11.4";
    src = pkgs.fetchzip {
      url = "https://github.com/emacs-tree-sitter/tree-sitter-langs/releases/download/${version}/tree-sitter-grammars-macos-${version}.tar.gz";
      stripRoot = false;
      sha256 = "sha256:03arb8agspmfvhm76djb6lwfj2xrcxqzcgsc08d771y7kasw79hq";
    };
    installPhase = ''
      install -d $out/langs/bin
      install -m444 * $out/langs/bin
    '';
  };

  tree-sitter-elixir = pkgs.stdenv.mkDerivation rec {
    name = "tree-sitter-elixir";
    version = "0.19.0";
    commit = "ec1c4cac1b2f0290c53511a72fbab17c47815d2b";
    src = pkgs.fetchzip {
      url = "https://github.com/elixir-lang/tree-sitter-elixir/archive/${commit}.zip";
      sha256 = "sha256:1knbazn7wcl69n6dzbyalvhf60h4r4s5npcyxri535ix2s335q2i";
    };

    phases = [ "unpackPhase" "installPhase" ];

    installPhase = ''
      install -d $out/share/queries
      install ${name}-${commit}/queries/* $out/share/queries
    '';
  };
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
        override = epkgs: epkgs // {
          tree-sitter-langs = epkgs.tree-sitter-langs.overrideAttrs (oldAttrs: {
            postPatch = oldAttrs.postPatch or "" + ''
              # fix prebuilt grammar files
              substituteInPlace ./tree-sitter-langs-build.el \
              --replace "tree-sitter-langs-grammar-dir tree-sitter-langs--dir"  "tree-sitter-langs-grammar-dir \"${tree-sitter-grammars}/langs\""
            '';
            #  + ''
            #   # patch elixir related files
            #   mkdir -p queries/elixir
            #   install -m444 ${tree-sitter-elixir}/share/queries/* queries/elixir
            # '';
          });
        };
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
