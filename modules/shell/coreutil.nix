{ pkgs, lib, username, ... }:

lib.mkMerge [
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        bashInteractive

        coreutils-prefixed
        findutils

        file
        pstree
        killall
        pv

        dos2unix

        custom.mg
        neofetch
      ];
    };
  }

  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        zip
        unzip
        enca
      ];
    };

    homebrew.brews = [ "unar" ];
  }
]
