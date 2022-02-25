{ pkgs, lib, username, ... }:


lib.mkMerge [
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        tarsnap
      ];

      programs.bash.shellAliases = {
        ",tarsnap" = "tarsnap --humanize-numbers";
        ",tarsnap-dashboard" = "tarsnap --list-archives && tarsnap --print-stats --humanize-numbers -f '*'";
        ",tarsnap-delete" = "tarsnap --humanize-numbers -d -f";
      };
    };
  }

  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        borgbackup

        # rsync for cloud storage
        rclone
      ];
    };

    homebrew.casks = [ "resilio-sync" ];
  }
]
