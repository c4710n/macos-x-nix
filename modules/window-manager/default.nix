{ config, pkgs, lib, username, ... }:
let
  mdSize = {
    gridLeft = "1:2:0:0:1:1";
    gridLeftXL = "1:7:0:0:5:1";
    gridRight = "1:2:1:0:1:1";
    gridRightXL = "1:7:2:0:5:1";
    gridCenter = "12:12:2:2:8:8";
    gridFull = "1:1:0:0:1:1";
  };


  xlSize = rec {
    xTotal = 41;
    xEdgeGap = 4;
    xMidGap = 1;
    width = (xTotal - xMidGap) / 2 - xEdgeGap;

    yTotal = 10;
    yEdgeGap = 1;
    height = (yTotal - 2 * yEdgeGap);

    gridCenter =
      let
        xOffset = 4;
        x = (xTotal - width) / 2 + xOffset;
        y = 0;
      in
      "${toString yTotal}:${toString xTotal}:${toString x}:${toString y}:${toString width}:${toString height}";

    gridLeft =
      let
        x = xEdgeGap;
        y = yEdgeGap;
      in
      "${toString yTotal}:${toString xTotal}:${toString x}:${toString y}:${toString width}:${toString height}";

    gridRight =
      let
        x = xEdgeGap + width + xMidGap;
        y = yEdgeGap;
      in
      "${toString yTotal}:${toString xTotal}:${toString x}:${toString y}:${toString width}:${toString height}";
  };

  displayInternal = "1";
  displayExternal = "2";

  emacsPackage = config.home-manager.users."${username}".programs.emacs.finalPackage;
  emacsApp = "${emacsPackage}/Applications/Emacs.app";

  chromiumPackage = pkgs.custom.marmaduke-chromium;
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
  openMainBrowser = "open -a ${chromiumApp} --args ${lib.concatStringsSep " " chromiumArgs}";

  libreWolfApp = "${pkgs.custom.macos-librewolf}/Applications/LibreWolf.app";
  openAltBrowser = "open -a ${libreWolfApp}";
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
    #extraConfig = ''
    # yabai -m rule --add app=Terminal grid=${gridRightXL}
    # yabai -m rule --add app=Preview grid=${gridLeftXL}

    # yabai -m rule --add app=Feishu grid=${gridCenter}
    # yabai -m rule --add app=NetNewsWire grid=${gridRightXL}
    # yabai -m rule --add app=VSCodium grid=${gridRightXL}
    #'';
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

      # make Terminal has the same keybindings for adjusting font size #

      # (alt + ctrl - +) -> (cmd - +)
      alt + ctrl - 0x19 [
        "terminal" : skhd -k 'cmd - 0x19'
        * ~
      ]

      # (alt + ctrl - -) -> (cmd - -)
      alt + ctrl - 0x27 [
        "terminal" : skhd -k 'cmd - 0x27'
        * ~
      ]

      # (alt + ctrl - *) -> (cmd - 0)
      alt + ctrl - 0x1A [
        "terminal" : skhd -k 'cmd + shift - 0x1A'
        * ~
      ]

      # Shortcuts #
      cmd - e        : open -a Launchpad
      cmd + ctrl - t : open -a WezTerm
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
      cmd + ctrl - c : ${openMainBrowser}
      cmd + ctrl + shift - c : ${openAltBrowser}

      cmd + ctrl - s : open -a Sizzy
      cmd + ctrl - d : open -a TablePlus
      cmd + ctrl - w : open -a Telegram
      cmd + ctrl - r : open -a NetNewsWire

      cmd + ctrl - i : open -a Figma
      cmd + ctrl - m : open -a Feishu

      # position window on normal size display
      cmd + ctrl - left  : ${pkgs.yabai}/bin/yabai -m window --grid ${mdSize.gridLeft}
      cmd + ctrl - right : ${pkgs.yabai}/bin/yabai -m window --grid ${mdSize.gridRight}
      cmd + ctrl - up    : ${pkgs.yabai}/bin/yabai -m window --grid ${mdSize.gridFull}
      cmd + ctrl - down  : ${pkgs.yabai}/bin/yabai -m window --grid ${mdSize.gridRightXL}

      # position window on big size display
      cmd + ctrl + shift - left  : ${pkgs.yabai}/bin/yabai -m window --grid ${xlSize.gridLeft}
      cmd + ctrl + shift - right : ${pkgs.yabai}/bin/yabai -m window --grid ${xlSize.gridRight}
      cmd + ctrl + shift - down : ${pkgs.yabai}/bin/yabai -m window --grid ${xlSize.gridCenter}

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
