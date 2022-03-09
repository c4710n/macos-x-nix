{ modulesPath
, config
, pkgs
, lib
, ...
}: (import ../../lib/create-virtualbox-image.nix {
  inherit modulesPath config pkgs lib;
  hostName = "dev-box";
  diskSize = 20;
  memorySize = 2;
})
