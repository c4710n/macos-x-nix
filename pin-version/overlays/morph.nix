let
  sources = import ../../nix/sources.nix;
  repo = sources.morph;
in
(self: super: {
  morph = super.callPackage "${repo}/default.nix" {
    version = repo.rev;
  };
})
