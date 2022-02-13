# 所有虚拟机使用两块网卡：
# + 第一块网卡，使用 NAT Network 方式（不是默认的 NAT）接入。虚拟机借助该网卡可
#   以使用宿主机接入的互联网服务。
# + 第二块网卡，使用 Host-Only 方式接入。宿主机借助该网卡和虚拟机通讯，主要用于
#   SSH 等服务。另外，还可以为第二块网卡设置固定 IP，方便使用。
#
# 为第一块网卡创建 NAT Network：
#
#    Preferences > Network
#
#
# 为第二块网卡创建一个 Host Network（用默认的网络地址 192.168.56.1 即可，不然还要
# 做多余的权限设置）：
#
#   File > Host Network Manager
#

{ pkgs, lib, secrets, username, ... }:

lib.mkMerge [
  (
    let
      hostName = "nix-builder";
      host = "192.168.56.128";
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
            HostName ${host}
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
          maxJobs = 2;
        }
      ];

      # Step 4 - create a shortcut for entering this machine
      #
      # + -o IdentitiesOnly=yes ::
      #   Ignore SSH Agent, only use the key which is set explicitly.
      #   This is useful when you have lots of keys in SSH Agent, which will trigger
      #   the login failure due to exceeding the maximum number of attempts.
      home-manager.users."${username}".programs.bash.shellAliases = {
        ",enter-nix-builder" = "sudo -p 'root password on macOS: ' ssh ${hostName}";
      };
    }
  )
]
