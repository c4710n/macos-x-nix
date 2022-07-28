{ ... }:
{
  imports = [
    ./base.nix
    ./input-device.nix
    ./networking.nix
    ./window-manager.nix
    ./input-method
    ./perf.nix
  ];
}
