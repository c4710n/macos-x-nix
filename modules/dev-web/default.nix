{ pkgs, username, ... }:

{
  # load testing
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      wrk
      tsung
    ];
  };

  homebrew.casks = [
    # color picker
    "menubar-colors"
    "colorpicker-propicker"
    "colorpicker-skalacolor"

    # better browser for developing web page
    # "sizzy" - currently, sizzy's download link is broken.
  ];
}
