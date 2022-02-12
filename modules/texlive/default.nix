{ pkgs, username, ... }:

{
  # Why you don't use `texlive.combined.scheme-full` which is provided by nixpkgs?
  # It is compiled with font-config which make fonts doesn't work properly on macOS.
  homebrew.casks = [ "mactex-no-gui" ];

  # It's best to add following line into shell profile:
  #
  #  eval "$(/usr/libexec/path_helper)"
  #
  # But, I don't want to pollute my PATH. So, I maintain it manually.
  home-manager.users."${username}" = {
    programs.bash.profileExtra = ''
      export PATH="/Library/TeX/texbin:$PATH"
    '';
  };
}
