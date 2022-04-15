{ username, homeDir, ... }:

{
  homebrew.casks = [ "wezterm" ];

  home-manager.users."${username}" = {
    home.file.".config/wezterm/wezterm.lua".source = ./files/wezterm.lua;
  };
}
