{ pkgs, lib, username, ... }:

lib.mkMerge [
  # fly.io
  {
    homebrew.taps = [ "superfly/tap" ];
    homebrew.brews = [ "flyctl" ];
  }

  # virtual machine
  {
    homebrew.casks = [ "virtualbox" "utm" ];
  }

  # docker
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        docker-client
        docker-compose_2
        dive
      ];

      programs.bash.initExtra = ''
        # my docker daemon is running in a virtual machine.
        export DOCKER_HOST="tcp://dev-box:2375"
      '' + builtins.readFile ./files/docker.sh;
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
