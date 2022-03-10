{ pkgs, lib, secrets, username, ... }:

let
  hostName = "dev-box";
in
lib.mkMerge [
  ({
    launchd.daemons."vbox-ensure-host-entry-${hostName}" =
      let
        command = "${pkgs.custom.vbox-ensure-host-entry}/bin/vbox-ensure-host-entry";
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
        serviceConfig.StandardOutPath = "/var/log/vbox-ensure-host-entry.log";
        serviceConfig.StandardErrorPath = "/var/log/vbox-ensure-host-entry.log";
      };
  })

  (
    let
      sshPort = 22;
      sshUser = "root";
      sshKeyPath = toString ../../secrets/nixos-vm-ssh-key-private;
    in
    {
      home-manager.users."${username}".programs.bash.shellAliases = {
        ",enter-dev-box" = "ssh -i ${sshKeyPath} ${sshUser}@${hostName}";
      };
    }
  )
]
