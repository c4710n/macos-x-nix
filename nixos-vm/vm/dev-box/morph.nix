let
  system = "x86_64-linux";
  secrets = import ../../../secrets.nix;
  sources = import ../../../nix/sources.nix;
  pkgs = import sources.nixos {
    system = system;
  };
in
{
  network = {
    inherit pkgs;
  };

  dev-box = {
    nixpkgs.localSystem.system = system;

    # This server is a local virtual machine, I prefer to upload derivations to
    # server directly.
    deployment.substituteOnDestination = false;

    deployment.targetHost = "dev-box";
    deployment.targetUser = "root";

    _module.args.secrets = secrets;
    _module.args.gateway = "192.168.56.1";

    imports =
      let
        general-configuration = import (../../shared/general-configuration.nix) {
          inherit secrets;
          hostName = "dev-box";
        };
      in
      [
        <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
        <nixpkgs/nixos/modules/virtualisation/virtualbox-guest.nix>
        general-configuration
        ./configuration.nix
      ];
  };
}
