{ username, ... }:

{
  # /etc/sysctl.conf is no longer supported with Big Sur.
  # To make persistent changes systctl can be issued on boot time using a launch daemon
  launchd.daemons.sysctl.serviceConfig = {
    RunAtLoad = true;
    LaunchOnlyOnce = true;
    ProgramArguments = [
      "/usr/sbin/sysctl"
      "kern.maxfiles=24000000"
      "kern.maxfilesperproc=12000000"
    ];
  };

  home-manager.users."${username}" = {
    programs.bash = {
      initExtra = ''
        ulimit -S -n 4000000
      '';

      shellAliases = {
        ",os-maxfiles" = ''
          sysctl -A | grep kern.maxfiles; echo "ulimit -n: $(ulimit -n)"
        '';
      };
    };
  };
}
