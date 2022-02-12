{ pkgs, lib, username, ... }:

lib.mkMerge [
  # alternative top-like tools
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        htop
      ];
    };

    homebrew.brews = [ "btop" ];
  }

  {
    homebrew.casks = [ "sloth" ];
  }
]
