{ pkgs, username, ... }:

{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      cmake

      custom.nodePackages.speedscope
    ];
  };
}
