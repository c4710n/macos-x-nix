{ config, pkgs, username, ... }:

{
  # force Nix to create links for system packages and user packages
  # + https://github.com/LnL7/nix-darwin/issues/139
  system.build.applications = pkgs.lib.mkForce (pkgs.buildEnv {
    name = "applications";
    paths = config.environment.systemPackages
      ++ config.home-manager.users."${username}".home.packages;
    pathsToLink = "/Applications";
  });

  # modify the activation script to create aliases which get picked up by `open`.
  system.activationScripts.applications.text = pkgs.lib.mkForce (
    ''
      echo "setting up ~/Applications/Nix..."
      rm -rf ~/Applications/Nix
      mkdir -p ~/Applications/Nix
      chown ${username} ~/Applications/Nix
      find ${config.system.build.applications}/Applications -maxdepth 1 -type l | while read f; do
        src="$(/usr/bin/stat -f%Y "$f")"
        appname="$(basename "$src")"
        osascript -e "tell app \"Finder\" to make alias file at POSIX file \"/Users/${username}/Applications/Nix/\" to POSIX file \"$src\" with properties {name: \"$appname\"}" > /dev/null 2>&1 \
        && echo "linking $src ..."
      done
    ''
  );
}
