{ modulesPath
, config
, pkgs
, lib
, hostName ? "nixos-vm"
, ip ? "192.168.56.2"
, diskSize ? 20
, memorySize ? 2
, ...
}:

let
  virtualbox-tune = import (../shared/virtualbox-tune.nix) {
    inherit hostName diskSize memorySize;
  };
  general-configuration = import (../shared/general-configuration.nix) {
    inherit hostName ip;
  };
in
{
  imports =
    [
      # `modulesPath` is equal to `nixpkgs/nixos/modules`
      "${modulesPath}/virtualisation/virtualbox-image.nix"
      "${modulesPath}/virtualisation/virtualbox-guest.nix"
      virtualbox-tune
      general-configuration
    ];
}
