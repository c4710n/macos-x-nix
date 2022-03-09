# Just as the name implies, I am running Nix on macOS whose architecture name
# is `x86_64-darwin`.
# Because the incompatibility of architecture, I can't build software for my
# `x86_64-linux` server without any effort.
#
# The core idea is:
# 1. run a `x86_64-linux` machine in macOS.
# 2. set the machine as the build machine for Nix.
#
# > Note: It requires Nix running in daemon mode.
#
#
# There are multiple ways to setup a machine:
# + run a docker container via [Docker Desktop](https://www.docker.com/products/docker-desktop)
#   and [nix-docker](https://github.com/LnL7/nix-docker).
# + run a virtual machine via type 2 virtualization software, such as VirtualBox.
#
# Personally, I don't like Docker, because it's using layed file system, and the
# used disk space that will not be reclaimed. Eventually, the container will take
# up a lot of space.
#
# So, I choose VirtualBox, and create a virtual machine within it.
#
# When I setup a virtual machine, I will create 2 NIC:
# 1. one for NAT (not NAT Network). The virtual machine accesses Internet
#    through host with the help of this NIC.
#
# 2. one for Host-only Network. The host uses this NIC to communicate with the
#    virtual machine, mainly for SSH.
#
#  > Create a Host Network before creating any NIC of Host Network.
#  > (The default subnet 192.168.56.1/24 is good)
#  > Try to click: File > Host Network Manager
#

{ pkgs, lib, secrets, username, ... }:

let
  hostName = "nix-builder";
in
lib.mkMerge [
  ({
    launchd.daemons."ensure-vbox-host-entry-${hostName}" =
      let
        command = "${pkgs.custom.ensure-vbox-host-entry}/bin/ensure-vbox-host-entry";
      in
      {
        serviceConfig.RunAtLoad = true;
        serviceConfig.KeepAlive = true;
        serviceConfig.StartInterval = 10;
        serviceConfig.ProgramArguments = [
          command
          username
          hostName
          "1"
        ];
        serviceConfig.StandardOutPath = "/var/log/ensure-vbox-host-entry.log";
        serviceConfig.StandardErrorPath = "/var/log/ensure-vbox-host-entry.log";
      };
  })

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
        echo '${secrets.nixos-vm-ssh-key-private}' > ${sshKeyPath}
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
          supportedFeatures = [ "kvm" ]; # required by nixos-generators
          maxJobs = 2;
        }
      ];

      # Step 4 - create a shortcut for entering this machine
      #
      # + -o IdentitiesOnly=yes ::
      #   Ignore SSH Agent, only use the key which is set explicitly.
      #   This is useful when there're lots of keys in SSH Agent, which will trigger
      #   the login failure due to exceeding the maximum number of attempts.
      home-manager.users."${username}".programs.bash.shellAliases = {
        ",enter-nix-builder" = "sudo -p 'root password on macOS: ' ssh ${hostName}";
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
