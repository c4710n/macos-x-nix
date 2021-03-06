{ pkgs, lib, username, ... }:

let
  pinned = import ../nix/sources.nix;
  pinnedNixpkgs = pinned.nixpkgs;
  pinnedNixDarwin = pinned.nix-darwin;
  pinnedHomeManager = pinned.home-manager;
in
{
  nix.nixPath = lib.mkForce [
    # Custom the location of configuration.nix
    # $ darwin-rebuild switch -I darwin-config=$HOME/.nixpkgs/configuration.nix
    "darwin-config=$HOME/.nixpkgs/configuration.nix"

    # Remove channels provided by root user and normal user.
    # Only use paths which are declared at here.
    "darwin=${pinnedNixDarwin}"
    "nixpkgs=${pinnedNixpkgs}"
    "nixpkgs-overlays=$HOME/.nixpkgs/pin-version/overlays"
  ];

  # configure overlays
  # + https://github.com/jwiegley/nix-config/blob/ec04d837e8bfae381a9a6ea11ad5f2b1680868c2/config/darwin.nix#L44
  #
  # nix-tools (nix-env, nix-shell, etc.):
  #   It is using overlays specified by `nixpkgs-overlays=`in env `NIX_PATH`.
  #
  # darwin-rebuild:
  #   It is using overlays specified by `nixpkgs.overlays` in Nix configuration.
  #   Note: `nixpkgs.overlays` is not used by nix-tools.
  #
  # To make them use the same source of overlays:
  # 1. setup `NIX_PATH=nixpkgs-overlays=$HOME/.nixpkgs/overlays...` for nix-tools.
  # 2. read overlays from `$HOME/.nixpkgs/overlays` and setup `nixpkgs.overlays` for `darwin-rebuild`.
  #
  nixpkgs.overlays =
    let
      path = ./overlays;
    in
    with builtins;
    map (n: import (path + ("/" + n)))
      (filter
        (n: match ".*\\.nix" n != null)
        (attrNames (readDir path)));


  # home-manager
  imports = [ "${pinnedHomeManager}/nix-darwin" ];
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  # homebrew
  homebrew = {
    enable = true;
    cleanup = "zap";
    global.brewfile = true;
    taps = [
      "homebrew/cask"
      "homebrew/cask-versions"
    ];
  };
  environment.variables = {
    HOMEBREW_NO_ANALYTICS = "1";
    HOMEBREW_NO_INSECURE_REDIRECT = "1";
    HOMEBREW_CASK_OPTS = "--require-sha";
  };

  # other config for home-manager and homebrew
  home-manager.users."${username}" = {
    home.enableNixpkgsReleaseCheck = true;

    manual.html.enable = true;

    programs.bash.initExtra = ''
      ,brew-use-path() {
        eval "$(/usr/libexec/path_helper)"
      }
    '';
  };
}
