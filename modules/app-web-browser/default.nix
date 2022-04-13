{ pkgs, username, ... }:

{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      custom.marmaduke-chromium
    ];
  };

  homebrew.casks = [
    "tor-browser"
  ];
}
