{ pkgs, username, ... }:

{
  home-manager.users."${username}" = {
    programs.firefox = import ./firefox { inherit pkgs; };

    home.packages = with pkgs; [
      custom.macos-chromium
    ];
  };

  homebrew.casks = [
    "tor-browser"
  ];
}
