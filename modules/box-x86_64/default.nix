# I am running Nix on M1 macOS.
#
# Because the incompatibility of architecture, I can't build software for my
# `x86_64-linux` machines.
#
# The core idea is:
# 1. run a `x86_64-linux` machine in macOS.
# 2. set the machine as the build machine for Nix.
#
# > Note: It requires Nix running in daemon mode.
#
#
# There are multiple ways to setup a machine:
# 1. run a docker container via [Docker Desktop](https://www.docker.com/products/docker-desktop)
#   and [nix-docker](https://github.com/LnL7/nix-docker).
# 2. run a virtual machine via type 2 virtualization software.
#
# Personally, I don't like Docker, because it's using layed file system, and the
# used disk space that will not be reclaimed. Eventually, the container will take
# up a lot of space.
#
# So, I choose way #2.

{ pkgs, lib, secrets, username, ... }:

let
  hostName = "box-x86_64";
in
lib.mkMerge [
  (
    let
      sshPort = 22;
      sshUser = "root";
      sshKeyPath = "/etc/nix/ssh_key_for_build_machines";
    in
    {
      # Step 1 - configure a build machine for x86_64-linux.
      # + create a virtual machine which installed NixOS
      # + setup path/to/ssh_public_key as SSH authorized key of root user.

      # Step 2 - copy SSH private key.
      system.activationScripts.extraActivation.text = ''
        echo '${secrets.nixos-vm-ssh-key}' > ${sshKeyPath}
        chmod 0600 ${sshKeyPath}
      '';

      home-manager.users."root" = {
        home.file.".ssh/config".text = ''
          Host ${hostName}
            User ${sshUser}
            Port ${toString sshPort}
            IdentityFile ${sshKeyPath}
            IdentitiesOnly yes
        '';
      };

      # Step 3 - setup this machine as a build machine.
      nix.distributedBuilds = true;
      nix.buildMachines = [
        {
          hostName = hostName;
          system = "x86_64-linux";
          supportedFeatures = [ "kvm" ];
          maxJobs = 2;
        }
      ];

      # Step 4 - create a shortcut for booting and entering this machine
      #
      # + -o IdentitiesOnly=yes ::
      #   Ignore SSH Agent, only use the key which is set explicitly.
      #   This is useful when there're lots of keys in SSH Agent, which will trigger
      #   the login failure due to exceeding the maximum number of attempts.
      home-manager.users."${username}".programs.bash.shellAliases = {
        ",boot-box-x86_64" = "open utm://start?name=box-x86_64";
        ",enter-box-x86_64" = "sudo -p 'root password on macOS: ' ssh ${hostName}";
      };

      # Step 5 - test
      #
      # Try to build `hello` package for `x86_64-linux` with `nix-build`:
      #
      #   nix-build -E 'with import <nixpkgs> { system = "x86_64-linux"; }; hello.overrideAttrs (drv: { rebuild = builtins.currentTime; })'
      #
      #
      # If everything works fine, similiar logs will be shown:
      #
      #   building '/nix/store/dn4ilscxwvl3ir1ajsdxp6j6abr6z2is-hello-2.10.drv' on 'ssh://nix-builder'...
      #
      # Notice that, 'ssh://nix-builder' is used.
      #
      # And, the `hello` package will be built without any error.
      #
    }
  )
]
