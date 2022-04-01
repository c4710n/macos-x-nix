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

        jq
        unstable.fq # jq for binary formats

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
