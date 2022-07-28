{ pkgs, lib, username, ... }:

lib.mkMerge [
  # necessary
  {
    homebrew.casks = [
      # better user experience
      "keepingyouawake"

      # system extension
      "macfuse"

      # system cleaner
      "appcleaner"
      # "daisydisk"
    ];
  }

  # security
  {
    homebrew.casks = [
      # application firewall
      # "lulu"

      # Oversight – camera-usage detection tool
      # "oversight"

      #  keylogger detection tool
      "reikey"
    ];
  }

  # backup
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        borgbackup

        # rsync for cloud storage
        rclone

        # tarsnap
      ];

      # programs.bash.shellAliases = {
      #   ",tarsnap" = "tarsnap --humanize-numbers";
      #   ",tarsnap-dashboard" = "tarsnap --list-archives && tarsnap --print-stats --humanize-numbers -f '*'";
      #   ",tarsnap-delete" = "tarsnap --humanize-numbers -d -f";
      # };
    };
  }

  # image
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        imagemagick
        # zbar
        qrencode
      ];
    };

    homebrew.casks = [
      "imageoptim"
      # "texturepacker"
    ];
  }

  # video
  {
    homebrew.casks = [
      "iina"
    ];
  }

  # design
  {
    homebrew.casks = [
      "figma"
    ];
  }

  # free world
  {
    homebrew.casks = [
      "c0re100-qbittorrent"
      "netnewswire"
    ];
  }

  # doc
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        pandoc
      ];
    };

    homebrew.casks = [ "monodraw" "calibre" ];
  }

  # communication
  {
    homebrew.casks = [
      "protonmail-bridge"
      "telegram"
      "feishu"
    ];
  }
]
