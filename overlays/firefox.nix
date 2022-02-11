let
  sources = import ../nix/sources.nix;
  repo = sources.nixpkgs-firefox-darwin;
in
import "${repo}/overlay.nix"
