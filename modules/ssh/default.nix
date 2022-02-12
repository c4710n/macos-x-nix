{ pkgs, username, ... }:

{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      keychain
    ];

    programs.bash.initExtra = (builtins.readFile ./files/bashrc.sh);
  };
}
