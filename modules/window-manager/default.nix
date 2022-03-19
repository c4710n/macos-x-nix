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

  emacsPackage = config.home-manager.users."${username}".programs.emacs.finalPackage;
  emacsApp = "${emacsPackage}/Applications/Emacs.app";

  firefoxPackage = config.home-manager.users."${username}".programs.firefox.package;
  firefoxApp = "${firefoxPackage}/Applications/Firefox.app";

  chromiumPackage = pkgs.custom.macos-chromium;
  chromiumApp = "${chromiumPackage}/Applications/Chromium.app";
  chromiumArgs = [
    # install extension manually
    "--extension-mime-request-handling"
    # remove useless UI
    "--custom-ntp='about:blank'"
    "--remove-tabsearch-button"
    "--show-avatar-button=never"
    "--bookmark-bar-ntp=never"
    # privary
    "--fingerprinting-canvas-image-data-noise"
    "--fingerprinting-canvas-measuretext-noise"
    "--fingerprinting-client-rects-noise"
    # others
    "--disable-search-engine-collection"
    "--enable-features=SetIpv6ProbeFalse"
  ];
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
        padding = 10;
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

      # Emulate Emacs keys #
      ctrl - m  : skhd -k 'return'
      ctrl - h  : skhd -k 'backspace'
      ctrl - n [
        "emacs" ~
        *       : skhd -k 'down'
      ]

      ctrl - p [
        "emacs" ~
        *       : skhd -k 'up'
      ]

      ctrl - b [
        "emacs" ~
        *       : skhd -k 'left'
      ]

      ctrl - f [
        "emacs" ~
        *       : skhd -k 'right'
      ]

      ctrl - v [
        "emacs" ~
        "terminal" ~
        *       : skhd -k 'pagedown'
      ]

      alt - v [
        "terminal" ~
        *       : skhd -k 'pageup'
      ]

      alt + shift - 0x0D [
        "emacs" ~
        *       : skhd -k 'home'
      ]

      alt + shift - 0x0E [
        "emacs" ~
        *       : skhd -k 'end'
      ]

      # Shortcuts #
      cmd - e        : open -a Launchpad
      cmd + ctrl - t : open -a Terminal
      cmd + ctrl - f : open -a Finder
      cmd + ctrl - g : open -a Dictionary
      cmd + ctrl - p : open -a Preview

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
                         open -a ${emacsApp} || \
                         bash -i -c 'open -a ${emacsApp}'

      # https://github.com/Eloston/ungoogled-chromium/blob/master/docs/flags.md
      cmd + ctrl - c : open -a ${chromiumApp} --args ${lib.concatStringsSep " " chromiumArgs}
      cmd + ctrl + shift - c : open -a ${firefoxApp}

      cmd + ctrl - s : open -a Sizzy
      cmd + ctrl - d : open -a TablePlus
      cmd + ctrl - n : open -a Telegram

      cmd + ctrl - i : open -a Figma
      cmd + ctrl - m : open -a Feishu

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
      cmd - w [
        "chromium" ~
        *       : true
      ]

      cmd - q : true
      cmd - h : true
    '';
  };
}
