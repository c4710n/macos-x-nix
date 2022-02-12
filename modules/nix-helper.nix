{ username, ... }:

{
  home-manager.users."${username}" = {
    programs.bash.initExtra = ''
      ## NIX ##
      ,nixos-available-options() {
        xdg-open https://nixos.org/nixos/options.html
      }

      ,nix-trace-cmd() {
        CMD=$1

        if [ -z $1 ]; then
          echo "No command provided. Exit."
          return
        fi

        if [[ "$OSTYPE" == "darwin"* ]]; then
          greadlink -e $(which $CMD)
        else
          readlink -e $(which $CMD)
        fi
      }

      ,nix-trace-file() {
        FILE=$1

        if [[ "$OSTYPE" == "darwin"* ]]; then
          greadlink -e $(which $FILE)
        else
          readlink -e $(which $FILE)
        fi
      }

      ,nixpkgs-search-system() {
        PATTERN=$1
        nix-env --query --available --description ".*$PATTERN.*"
      }

      ,nixpkgs-search-emacs() {
        PATTERN=$1
        nix-env -f "<nixpkgs>" -qaP -A emacsPackages.elpaPackages | grep $PATTERN
        nix-env -f "<nixpkgs>" -qaP -A emacsPackages.melpaPackages | grep $PATTERN
        nix-env -f "<nixpkgs>" -qaP -A emacsPackages.melpaStablePackages | grep $PATTERN
        nix-env -f "<nixpkgs>" -qaP -A emacsPackages.orgPackages | grep $PATTERN
      }

      ,nixpkgs-search-python() {
        PATTERN=$1
        nix-env -f "<nixpkgs>" -qaP -A python2Packages | grep $PATTERN
        nix-env -f "<nixpkgs>" -qaP -A python3Packages | grep $PATTERN
      }

      ,nixpkgs-search-node() {
        PATTERN=$1
        nix-env -f "<nixpkgs>" -qaP -A nodePackages
      }

      ,nixpkgs-search-nur() {
        echo "Opening NUR PACKAGE SEARCH in your default web browser..."
        xdg-open 'https://nix-community.github.io/nur-search/'
        echo "If it miss something, checkout git repo - nur-combined:"
        echo ""
        echo "  + https://github.com/nix-community/nur-combined"
        echo ""
      }

      ,nix-prefetch-unstable() {
        revision=$1
        url="https://github.com/NixOS/nixpkgs/archive/$revision.tar.gz"
        nix-prefetch-url --unpack "$url"
      }

      ,nix-prefetch-home-manager() {
        revision=$1
        url="https://github.com/nix-community/home-manager/archive/$revision.tar.gz"
        nix-prefetch-url --unpack "$url"
      }

      ,nix-prefetch-nur() {
        revision=$1
        url="https://github.com/nix-community/NUR/archive/$revision.tar.gz"
        nix-prefetch-url --unpack "$url"
      }

      ,nix-prefetch-emacs-overlay() {
        revision=$1
        url="https://github.com/nix-community/emacs-overlay/archive/$revision.tar.gz";
        nix-prefetch-url --unpack "$url"
      }
    '';
  };
}
