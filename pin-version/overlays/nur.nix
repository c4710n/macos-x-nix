let
  sources = import ../../nix/sources.nix;
  repo = sources.NUR;
in
(self: super: {
  nur = import repo { inherit super; };
})
