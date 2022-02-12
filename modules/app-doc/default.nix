{ pkgs, username, ... }:

{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      # python39Packages.grip
      pandoc
    ];
  };

  homebrew.casks = [ "monodraw" ];
}
