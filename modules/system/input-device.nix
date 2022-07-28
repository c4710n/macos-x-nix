{ lib, ... }:

lib.mkMerge [
  # keyboard
  {
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
      # swapLeftCommandAndLeftAlt = true;
    };

    system.defaults = {
      NSGlobalDomain = {
        # enable standard function keys
        "com.apple.keyboard.fnState" = true;

        # set a faster keyboard repeat rate
        KeyRepeat = 2;
        InitialKeyRepeat = 10;
      };
    };
  }

  # trackpad
  {
    system.defaults = {
      trackpad.Clicking = true;
    };
  }
]
