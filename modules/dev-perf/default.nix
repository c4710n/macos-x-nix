{ pkgs, username, ... }:

{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      # most of the time, use speedscope
      custom.nodePackages.speedscope

      # when the file is too large to load in speedscope, use flamegraph
      flamegraph
    ];
  };
}
