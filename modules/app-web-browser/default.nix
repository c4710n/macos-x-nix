{ pkgs, username, ... }:

{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      custom.macos-chromium
    ];
  };

  homebrew.casks = [
    "tor-browser"
  ];
}
