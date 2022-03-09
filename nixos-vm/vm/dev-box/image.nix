{ modulesPath
, config
, pkgs
, lib
, ...
}: (import ../../lib/create-virtualbox-image.nix {
  inherit modulesPath config pkgs lib;
  hostName = "dev-box";
  ip = "192.168.56.10";
  diskSize = 20;
  memorySize = 2;
})
