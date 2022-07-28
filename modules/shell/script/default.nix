{ pkgs, username, ... }:

let
  path = ".config/scripts";
in
{
  home-manager.users."${username}" = {
    home.file."${path}/general".source = ./files/general;
    home.file."${path}/macos".source = ./files/macos;
    programs.bash.profileExtra = ''
      export PATH="$HOME/${path}/general:$HOME/${path}/macos:$PATH"
    '';
  };
}
