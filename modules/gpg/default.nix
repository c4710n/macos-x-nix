{ pkgs, username, homeDir, ... }:

{
  home-manager.users."${username}" = {
    programs.gpg = {
      enable = true;
      settings = {
        # when outpputting certificates, view user IDs distinctly from keys
        "fixed-list-mode" = true;

        # long keyids are more collision-resistant than short keyids
        # it's trivial to make a key with any desired short keyid
        "keyid-format" = "0xlong";
      };
    };

    home.packages = with pkgs; [
      paperkey
    ];
  };
}
