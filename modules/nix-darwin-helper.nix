{ username, ...}:

{
  home-manager.users."${username}" = {
    programs.bash.shellAliases = {
      ",nix-darwin-test" = "darwin-rebuild switch -I darwin=.";
    };
  };
}
