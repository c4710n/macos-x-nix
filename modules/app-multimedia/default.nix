{ pkgs, lib, username, ... }:

with lib;

mkMerge [
  # image
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        imagemagick
        zbar
        qrencode
      ];
    };

    homebrew.casks = [
      "imageoptim"
      "texturepacker"
    ];
  }

  # video
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        ffmpeg
        youtube-dl
      ];

      programs.bash.shellAliases = {
        ",youtube-dl-music" =
          "youtube-dl -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata";
      };

      # video player
      programs.mpv = {
        enable = true;

        config = {
          geometry = "50%:50%";
          autofit = "80%x80%";
          keep-open = "always";
          osd-fractions = true;
          osd-font-size = 90;
          osd-border-size = 10;
          sub-auto = "fuzzy";
        };
      };
    };

    homebrew.casks = [
      "iina"
    ];
  }
]
