let
  sources = import ../../nix/sources.nix;
  mix-to-nix = sources.mix-to-nix;
in
(self: pkgs: {
  mix-to-nix = pkgs.callPackage mix-to-nix { };
})
