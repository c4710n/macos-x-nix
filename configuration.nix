{ lib, config, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in
{
  # Necessary packages for managing this repo.
  environment.systemPackages = with pkgs;[
    # the tool for pinning versions
    niv

    # the tool for managing secrets
    git-crypt

    # the tool for manageing local virtual machines
    morph
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # index nixpkgs
  programs.nix-index.enable = true;

  # pass useful args for all modules
  _module.args.secrets = secrets;
  _module.args.username = secrets.username;
  _module.args.homeDir = "/Users/${secrets.username}";
  _module.args.hostConfig = import ./hosts/current.nix;

  imports = [
    ./packages
    ./pin-version

    ./modules/nix-helper.nix
    ./modules/nix-darwin-helper.nix

    ./modules/link-app
    ./modules/ui
    ./modules/timezone
    ./modules/font
    ./modules/input-device
    ./modules/perf
    ./modules/window-manager
    ./modules/networking
    ./modules/disable-useless-feature
    ./modules/software-update

    ./modules/gpg
    ./modules/password
    ./modules/ssh

    ./modules/cli-base
    ./modules/bash
    ./modules/bash-script
    ./modules/git
    ./modules/emacs
    ./modules/direnv
    ./modules/tmux
    # ./modules/texlive

    ./modules/nix-builder

    ./modules/app-necessary
    ./modules/app-security
    ./modules/app-terminal
    ./modules/app-input-method
    ./modules/app-web-browser
    ./modules/app-multimedia
    ./modules/app-design
    ./modules/app-im
    ./modules/app-doc
    ./modules/app-storage
    ./modules/app-free-world

    ./modules/dev-general
    ./modules/dev-perf
    ./modules/dev-font
    ./modules/dev-web
    ./modules/dev-network
    ./modules/dev-database
    ./modules/dev-deployment
    ./modules/dev-system-monitor
    ./modules/lang-elixir
    ./modules/lang-nodejs
    ./modules/lang-python

    ./modules/app-work
  ];
}
