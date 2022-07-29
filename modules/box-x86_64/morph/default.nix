let
  system = "x86_64-linux";
  secrets = import ../../../secrets.nix;
  sources = import ../../../nix/sources.nix;
  pkgs = import sources.nixos {
    system = system;
  };

  hostname = "box-x86_64";
in
{
  network = {
    inherit pkgs;
  };

  box-x86_64 = {
    nixpkgs.localSystem.system = system;

    # This server is a local virtual machine, I prefer to upload derivations to
    # server directly.
    deployment.substituteOnDestination = false;

    deployment.targetHost = hostname;
    deployment.targetUser = "root";

    _module.args.secrets = secrets;
    _module.args.hostname = hostname;

    imports =
      [
        ./configuration.nix
        ./application.nix
      ];
  };
}
