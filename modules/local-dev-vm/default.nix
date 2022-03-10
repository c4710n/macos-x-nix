{ pkgs, lib, secrets, username, ... }:

let
  hostName = "dev-box";
in
lib.mkMerge [
  ({
    launchd.daemons."vbox-ensure-headless-run-${hostName}" =
      let
        command = "${pkgs.custom.vbox-ensure-headless-run}/bin/vbox-ensure-headless-run";
        logFile = "/var/log/vbox-ensure-headless-run.log";
      in
      {
        serviceConfig.RunAtLoad = true;
        serviceConfig.StartInterval = 10;
        serviceConfig.ProgramArguments = [
          "/bin/sh"
          "-c"
          "/bin/wait4path ${command} && exec ${command} ${username} ${hostName}"
        ];
        serviceConfig.StandardOutPath = logFile;
        serviceConfig.StandardErrorPath = logFile;
      };
  })

  ({
    launchd.daemons."vbox-ensure-host-entry-${hostName}" =
      let
        command = "${pkgs.custom.vbox-ensure-host-entry}/bin/vbox-ensure-host-entry";
        logFile = "/var/log/vbox-ensure-host-entry.log";
      in
      {
        serviceConfig.RunAtLoad = true;
        serviceConfig.StartInterval = 10;
        serviceConfig.ProgramArguments = [
          "/bin/sh"
          "-c"
          "/bin/wait4path ${command} && exec ${command} ${username} ${hostName} 1"
        ];
        serviceConfig.StandardOutPath = logFile;
        serviceConfig.StandardErrorPath = logFile;
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
