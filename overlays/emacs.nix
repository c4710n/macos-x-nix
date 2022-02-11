let
  sources = import ../nix/sources.nix;
  repo = sources.emacs-overlay;
in
import repo
