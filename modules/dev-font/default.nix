{ pkgs, username, ... }:

{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      python39Packages.fonttools
      fontforge
    ];
  };
}
