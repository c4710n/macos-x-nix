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
    "pika"

    # better browser for developing web page
    # "sizzy" - currently, sizzy's download link is broken.
  ];
}
