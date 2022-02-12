{ pkgs, lib, username, ... }:

lib.mkMerge [
  # fly.io
  {
    homebrew.taps = [ "superfly/tap" ];
    homebrew.brews = [ "flyctl" ];
  }

  # virtualbox
  {
    homebrew.casks = [ "virtualbox" ];
  }

  # docker
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        docker-client
        docker-compose_2
        dive
      ];

      programs.bash.initExtra = builtins.readFile ./files/docker.sh;
    };
  }

  # kubrenetes
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs;
        [
          kubernetes-helm
          kubectl
        ];
    };
  }
]
