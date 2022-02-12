let
  sources = import ../../nix/sources.nix;
  repo = sources.NUR;
in
(self: pkgs: {
  nur = import repo { inherit pkgs; };
})
