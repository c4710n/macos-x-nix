{ config, pkgs, system, ... }:

let
  pinned = import ../nix/sources.nix;
in
{
  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs: {
      unstable = import pinned.nixpkgs-unstable {
        config = config.nixpkgs.config;
      };

      custom = {
        mg = pkgs.callPackage ./mg { };
        trojan = pkgs.callPackage ./trojan { };
        sarasa-mono-sc-nerd-font = pkgs.callPackage ./sarasa-mono-sc-nerd-font { };
        pragmata-pro-font = pkgs.callPackage ./pragmata-pro-font { };
        macos-chromium = pkgs.callPackage ./macos-chromium { };
        macos-librewolf = pkgs.callPackage ./macos-librewolf { };
        ensure-vbox-host-entry = pkgs.callPackage ./ensure-vbox-host-entry { };

        nodePackages = import ./node-packages {
          inherit pkgs system;
        };
      };
    };
  };
}
