{ ... }:

let
  secrets = import ../secrets.nix;
  username = secrets.username;
in
{
  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users."${username}" = {
    manual.html.enable = true;
  };
}
