{ modulesPath
, config
, pkgs
, lib
, ...
}: (import ../../lib/create-virtualbox-image.nix {
  inherit modulesPath config pkgs lib;
  hostName = "nix-builder";
  ip = "192.168.56.128";
  diskSize = 20;
  memorySize = 2;
})
