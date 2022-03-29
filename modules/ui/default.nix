{ lib, username, homeDir, ... }:

lib.mkMerge [
  # login window
  {
    system.defaults.loginwindow.GuestEnabled = false;
    system.defaults.loginwindow.SHOWFULLNAME = true;
  }

  # wallpaper
  (
    let
      wallpaper = ./wallpaper/graceful-blue.png;
    in
    {
      system.activationScripts.extraActivation.text = ''
        osascript -e 'tell application "Finder" to set desktop picture to POSIX file "${wallpaper}"'
      '';
    }
  )

  # finder
  {
    system.defaults.finder = {
      AppleShowAllExtensions = true;

      # show full POSIX path as Finder window title
      _FXShowPosixPathInTitle = true;

      # disable the warning when changing a file extension
      FXEnableExtensionChangeWarning = false;
    };

    # show file extensions in Finder
    system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
  }

  # launch pad
  {
    # sort apps in default order
    system.activationScripts.extraActivation.text = ''
      defaults write com.apple.dock ResetLaunchPad -bool true
      killall Dock
    '';
  }

  # menu bar
  # auto hide it. It requires relogin after switching this option.
  {
    system.defaults.NSGlobalDomain._HIHideMenuBar = true;
  }

  # dock
  {
    system.defaults.dock = {
      autohide = true;
      orientation = "bottom";

      # set the icon size of all dock items
      tilesize = 30;

      # show open applications only
      static-only = true;

      # show indicator lights for open applications
      show-process-indicators = true;

      # don't automatically rearrange spaces based on the most recent one
      mru-spaces = false;

      # show hidden applications as translucent
      showhidden = true;
    };
  }

  # misc
  {
    # disable autocomplete of native UI
    system.defaults.NSGlobalDomain = {
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
    };
  }
]
