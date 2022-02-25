{ config, pkgs, lib, username, ... }:
let
  launchTerminal = pkgs.writeScriptBin "terminal" ''
    #!${pkgs.stdenv.shell}

    function pgrep() {
      ps aux | grep $1 | grep -v grep
    }

    # pgrep provided by macOS is invalid for Terminal,
    # I have to use a customized pgrep at here. ;(
    if pgrep 'MacOS/Terminal'; then
      exec osascript -e 'tell application "System Events"
        set frontmost of process "Terminal" to true
      end tell'
    else
      exec open -a Terminal ~
    fi
  '';

  gridLeft = "1:2:0:0:1:1";
  gridLeftXL = "1:7:0:0:5:1";
  gridRight = "1:2:1:0:1:1";
  gridRightXL = "1:7:2:0:5:1";
  gridCenter = "12:12:2:2:8:8";
  gridFull = "1:1:0:0:1:1";
  displayInternal = "1";
  displayExternal = "2";
in
{
  environment.systemPackages = [
    config.services.yabai.package
    config.services.skhd.package
  ];

  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    config =
      let
        padding = 0;
      in
      {
        top_padding = padding;
        bottom_padding = padding;
        left_padding = padding;
        right_padding = padding;
        window_gap = padding;
      };
    extraConfig = ''
      yabai -m rule --add app=Terminal grid=${gridRightXL}
      yabai -m rule --add app=Preview grid=${gridLeftXL}

      yabai -m rule --add app=Feishu grid=${gridCenter}
      yabai -m rule --add app=NetNewsWire grid=${gridRightXL}
      yabai -m rule --add app=VSCodium grid=${gridRightXL}
    '';
  };

  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    skhdConfig = ''
      # Emulate Keys #
      #
      # complete list of AppleScript key codes
      # https://eastmanreference.com/complete-list-of-applescript-key-codes

      # return
      # ctrl - m -> : skhd -k 'return'
      # 0x24      : true # train myself to use ctrl-m

      # delete
      # ctrl - h -> : skhd -k 'delete'
      # 0x33      : true

      # Shortcuts #
      cmd - e        : open -a Launchpad
      cmd + ctrl - t : open -a Terminal

      # If Emacs is not opened, then open it with a interactive shell,
      # or some functions might not work as expected, such as:
      # + `direnv` will not load PATH
      # + ...
      #
      # And:
      # + I need opening with a full path, or the packages installed by Nix will
      #   not be loaded properly.
      # + If the Emacs is opened, then you can switch to it with a simple 'open' call.
      cmd + ctrl - e : pgrep -f 'Applications/Emacs.app' && \
                         open -a Emacs || \
                         bash -i -c 'open -a Emacs.app'

      cmd + ctrl - f : open -a Finder
      cmd + ctrl - c : open -a Firefox
      cmd + ctrl + shift - c : open -a Chromium
      cmd + ctrl - s : open -a Sizzy
      cmd + ctrl - b : open -a Dash
      cmd + ctrl - d : open -a TablePlus
      cmd + ctrl - p : open -a Preview
      cmd + ctrl - i : open -a Figma
      cmd + ctrl - n : open -a NetNewsWire
      cmd + ctrl - m : open -a Feishu
      cmd + ctrl - w : open -a Telegram
      cmd + ctrl - l : open -a Spotify
      cmd + ctrl - v : open -a WeChat

      cmd + ctrl - left  : ${pkgs.yabai}/bin/yabai -m window --grid ${gridLeft}
      cmd + ctrl - right : ${pkgs.yabai}/bin/yabai -m window --grid ${gridRight}
      cmd + ctrl - up    : ${pkgs.yabai}/bin/yabai -m window --grid ${gridFull}
      cmd + ctrl - down  : ${pkgs.yabai}/bin/yabai -m window --grid ${gridRightXL}
      cmd - up           : ${pkgs.yabai}/bin/yabai -m display --focus ${displayExternal}
      cmd - down         : ${pkgs.yabai}/bin/yabai -m display --focus ${displayInternal}
      cmd + shift - up   : ${pkgs.yabai}/bin/yabai -m window --display ${displayExternal} && \
                             ${pkgs.yabai}/bin/yabai -m display --focus ${displayExternal}
      cmd + shift - down : ${pkgs.yabai}/bin/yabai -m window --display ${displayInternal} && \
                             ${pkgs.yabai}/bin/yabai -m display --focus ${displayInternal}

      # default keybindings provided by macOS
      # cmd - h        : Hide Current Window
      # cmd + ctrl - q : Lock Screen

      # restart yabai and skhd
      cmd + ctrl - r: pkill skhd; pkill yabai

      # disable default keybindings
      cmd - w : true
      cmd - q : true
      cmd - h : true
    '';
  };
}
