{ pkgs, system }:

let
  nodePackages = import ./node2nix {
    inherit pkgs system;
    nodejs = pkgs.nodejs-14_x;
  };
in
nodePackages
