{ modulesPath
, config
, pkgs
, lib
, ...
}: (import ../../lib/create-virtualbox-image.nix {
  inherit modulesPath config pkgs lib;
  hostName = "nix-builder";
  diskSize = 20;
  memorySize = 2;
})
