{ lib, config, pkgs, ... }:

let
  secrets = import ./secrets.nix;

  # source code from https://github.com/NixOS/nixpkgs/blob/1c00bf394867b07ed7a908408d8bc1d0afd9fa49/lib/strings.nix#L709
  readPathsFromFile = rootPath: file:
    let
      lines = lib.splitString "\n" (lib.readFile file);
      removeComments = lib.filter (line: line != "" && !(lib.hasPrefix "#" line));
      relativePaths = removeComments lines;
      paths = map (path: rootPath + "/${path}") relativePaths;
    in
    paths;

  privateExtensionsListFile = ./private-extensions.list;
in
{
  # Necessary packages for managing this repo.
  environment.systemPackages = with pkgs;[
    # the tool for pinning versions
    niv

    # the tool for managing secrets
    git-crypt

    # the tool for manageing local virtual machines
    morph
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # index nixpkgs
  programs.nix-index.enable = true;

  # pass useful args for all modules
  _module.args.secrets = secrets;
  _module.args.username = secrets.username;
  _module.args.homeDir = "/Users/${secrets.username}";
  _module.args.hostConfig = import ./hosts/current.nix;

  imports = ([
    ./packages
    ./pin-version

    ./modules/nix-helper.nix
    ./modules/nix-darwin-helper.nix

    ./modules/system
    ./modules/secret
    ./modules/shell
    ./modules/git

    ./modules/terminal
    ./modules/emacs

    ./modules/dev

    ./modules/application

    # ./modules/texlive

    # ./modules/nix-builder
    # ./modules/local-dev-vm

    # ./modules/dev-deployment
  ] ++ (
    # import private extensions
    if lib.pathExists privateExtensionsListFile then
      readPathsFromFile /. privateExtensionsListFile
    else
      [ ]
  ));
}
