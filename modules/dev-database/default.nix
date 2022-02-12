{ pkgs, username, ... }:

{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      postgresql_14
      mysql80
      redis

      pgcli
      mycli
    ];
  };

  homebrew.casks = [
    "tableplus"
  ];
}
