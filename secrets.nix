# Usage
#
#     secrets = import ./secrets.nix;
#
# It will read all files in ./secrets dir:
# + read text file as text.
# + import Nix file as nix expression.

with builtins;
let
  nixpkgs = import <nixpkgs> { };
  lib = nixpkgs.lib;
  readText = name: lib.removeSuffix "\n" (readFile (./secrets + "/${name}"));
  importNix = name: (import "${./secrets}/${name}");
in
mapAttrs
  (
    name: type:
      if type == "regular" then
        if lib.hasSuffix ".nix" name then
          importNix name
        else
          readText name
      else
        null
  )
  (readDir ./secrets)
