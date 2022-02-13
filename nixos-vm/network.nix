let
  system = "x86_64-linux";
  secrets = import ../secrets.nix;
  sources = import ../nix/sources.nix;
  pkgs = import sources.nixos {
    system = system;
  };
in
{
  network = {
    inherit pkgs;
  };

  nixos-vm-1 = {
    nixpkgs.localSystem.system = system;

    # This server is a local virtual machine, I prefer to upload derivations to
    # server directly.
    deployment.substituteOnDestination = false;

    deployment.targetHost = "192.168.56.10";
    deployment.targetUser = "root";

    networking.hostName = "nixos-vm-1";

    _module.args.secrets = secrets;
    _module.args.gateway = "192.168.56.1";

    imports = [
      ./hardware-configuration.nix
      ./configuration.nix
    ];
  };
}
