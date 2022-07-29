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
        marmaduke-chromium = pkgs.callPackage ./marmaduke-chromium { };
        thorium-chromium = pkgs.callPackage ./thorium-chromium { };
        macos-librewolf = pkgs.callPackage ./macos-librewolf { };

        vbox-ensure-host-entry = pkgs.callPackage ./vbox-ensure-host-entry { };
        vbox-ensure-headless-run = pkgs.callPackage ./vbox-ensure-headless-run { };

        nodePackages = import ./node-packages {
          inherit pkgs system;
        };

        plds = pkgs.callPackage ./plds { };
      };
    };
  };
}
