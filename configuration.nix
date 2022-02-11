{ lib, config, pkgs, ... }:

{
  # Necessary packages for managing this repo.
  environment.systemPackages = with pkgs;[
    # the tool for pinning versions
    niv

    # the tool for manage secrets
    git-crypt
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
