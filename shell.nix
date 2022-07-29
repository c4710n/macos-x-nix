{ pinned ? import ./nix/sources.nix, ... }:

let
  nixpkgs = pinned.nixpkgs;
  nixDarwin = pinned.nix-darwin;

  pkgs = import nixpkgs { };
  lib = pkgs.lib;

  nixPath = [
    "darwin-config=$HOME/.nixpkgs/configuration.nix"
    "darwin=${nixDarwin}"
    "nixpkgs=${nixpkgs}"
    "nixpkgs-overlays=$HOME/.nixpkgs/pin-version/overlays"
  ];
in
pkgs.mkShell {
  shellHook = ''
    export NIX_PATH="${lib.concatStringsSep ":" nixPath}"
  '';
}
