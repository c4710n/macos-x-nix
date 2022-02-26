{ pkgs, system }:

let
  nodePackages = import ./node2nix {
    inherit pkgs system;
  };
in
nodePackages
