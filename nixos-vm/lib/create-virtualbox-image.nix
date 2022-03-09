{ modulesPath
, config
, pkgs
, lib
, hostName ? "nixos-vm"
, diskSize ? 20
, memorySize ? 2
, ...
}:

let
  secrets = import ../../secrets.nix;

  virtualbox-tune = import (../shared/virtualbox-tune.nix) {
    inherit hostName diskSize memorySize;
  };

  general-configuration = import (../shared/general-configuration.nix) {
    inherit hostName secrets;
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
