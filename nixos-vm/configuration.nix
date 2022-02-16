{ config, pkgs, lib, secrets, gateway, ... }:

with lib;

let
  ip = config.deployment.targetHost;
in
lib.mkMerge [
  {
    # Set your time zone.
    time.timeZone = "Asia/Shanghai";

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;
    networking.enableIPv6 = false;
    networking.interfaces.enp0s3.useDHCP = true;
    networking.interfaces.enp0s8 = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = ip;
          prefixLength = 24;
        }
      ];
    };

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    environment.systemPackages = with pkgs; [ mg ];

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.permitRootLogin = "prohibit-password";
    users.users.root.openssh.authorizedKeys.keys = [ secrets.nixos-vm-ssh-key-public ];

    networking.firewall.enable = true;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "21.11"; # Did you read the comment?
  }

  # Web Server
  {
    services.caddy.enable = true;
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  }

  # Docker
  {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      storageDriver = "overlay2";
      logDriver = "journald";
      autoPrune.enable = true;
      liveRestore = true;
    };
  }

  # PostgreSQL
  {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_14;
      enableTCPIP = true;
      port = 5432;
      initdbArgs = [
        # https://github.com/docker-library/postgres/blob/a83005b407ee6d810413500d8a041c957fb10cf0/12/bullseye/docker-entrypoint.sh#L91
        # https://github.com/NixOS/nixpkgs/blob/9f697d60e4d9f08eacf549502528bfaed859d33b/nixos/modules/services/databases/postgresql.nix#L349
        "--pwfile=<(echo 'postgres')"
      ];
      authentication = ''
        # allow connections from local
        host all all ${gateway}/32 md5
      '';
    };

    networking.firewall.allowedTCPPorts = [ config.services.postgresql.port ];
  }

  # Redis
  {
    services.redis = {
      enable = true;
      bind = ip;
      openFirewall = true;
    };
  }

  # MySQL
  (
    let
      mysql_root_host = "%";
      mysql_root_password = "mysql";
      port = 3306;

      exporter_user = "exporter";
      exporter_password = "password_for_exporter";
    in
    {
      services.mysql = {
        enable = true;
        package = pkgs.mysql80;
        settings = {
          mysqld = {
            port = 3306;

            # disable binlog for dev environment
            disable_log_bin = true;

            # enable slow query log
            slow_query_log = true;
            long_query_time = 5;
          };
        };

        # https://github.com/NixOS/nixpkgs/blob/fbd030fb2d8dc9fedcb45e57cbce5e9e064bfb6c/nixos/modules/services/databases/mysql.nix#L454
        # https://github.com/docker-library/mysql/blob/f4032a1af40618ab81ecfe03ce0366aeb9f5af5e/8.0/docker-entrypoint.sh#L265
        initialScript = pkgs.writeText "initial-script" ''
          CREATE USER 'root'@'${mysql_root_host}' IDENTIFIED BY '${mysql_root_password}' ;
          GRANT ALL ON *.* TO 'root'@'${mysql_root_host}' WITH GRANT OPTION ;

          CREATE USER '${exporter_user}'@'localhost' IDENTIFIED BY '${exporter_password}' WITH MAX_USER_CONNECTIONS 3;
          GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO '${exporter_user}'@'localhost';
        '';
      };

      networking.firewall.allowedTCPPorts = [ port ];
    }
  )

  (
    let
      user = "mysqld-exporter";
      group = "mysqld-exporter";
      listenAddress = "127.0.0.1";
      port = 9104;
      extraFlags = [
        "--collect.auto_increment.columns"
        "--collect.binlog_size"
        "--collect.engine_innodb_status"
        "--collect.global_status"
        "--collect.global_variables"
        "--collect.info_schema.clientstats"
        "--collect.info_schema.innodb_metrics"
        "--collect.info_schema.innodb_tablespaces"
        "--collect.info_schema.innodb_cmp"
        "--collect.info_schema.innodb_cmpmem"
        "--collect.info_schema.processlist"
        "--collect.info_schema.query_response_time"
        "--collect.info_schema.replica_host"
        "--collect.info_schema.tables"
        "--collect.info_schema.tables.databases '*'"
        "--collect.info_schema.tablestats"
        "--collect.info_schema.schemastats"
        "--collect.info_schema.userstats"
        "--collect.mysql.user"
        "--collect.perf_schema.eventsstatements"
        "--collect.perf_schema.eventsstatementssum"
        "--collect.perf_schema.eventswaits"
        "--collect.perf_schema.file_events"
        "--collect.perf_schema.file_instances"
        "--collect.perf_schema.indexiowaits"
        "--collect.perf_schema.memory_events"
        "--collect.perf_schema.tableiowaits"
        "--collect.perf_schema.tablelocks"
        "--collect.perf_schema.replication_group_members"
        "--collect.perf_schema.replication_group_member_stats"
        "--collect.perf_schema.replication_applier_status_by_worker"
      ];

      exporter_user = "exporter";
      exporter_password = "password_for_exporter";
    in
    {

      systemd.services."prometheus-mysqld-exporter" = {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig.Restart = mkDefault "always";
        serviceConfig.PrivateTmp = mkDefault true;
        serviceConfig.WorkingDirectory = mkDefault /tmp;
        serviceConfig.DynamicUser = true;
        serviceConfig.User = user;
        serviceConfig.Group = group;
        # Hardening
        serviceConfig.CapabilityBoundingSet = mkDefault [ "" ];
        serviceConfig.DeviceAllow = [ "" ];
        serviceConfig.LockPersonality = true;
        serviceConfig.MemoryDenyWriteExecute = true;
        serviceConfig.NoNewPrivileges = true;
        serviceConfig.PrivateDevices = true;
        serviceConfig.ProtectClock = mkDefault true;
        serviceConfig.ProtectControlGroups = true;
        serviceConfig.ProtectHome = true;
        serviceConfig.ProtectHostname = true;
        serviceConfig.ProtectKernelLogs = true;
        serviceConfig.ProtectKernelModules = true;
        serviceConfig.ProtectKernelTunables = true;
        serviceConfig.ProtectSystem = mkDefault "strict";
        serviceConfig.RemoveIPC = true;
        serviceConfig.RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        serviceConfig.RestrictNamespaces = true;
        serviceConfig.RestrictRealtime = true;
        serviceConfig.RestrictSUIDSGID = true;
        serviceConfig.SystemCallArchitectures = "native";
        serviceConfig.UMask = "0077";

        serviceConfig.Environment = [
          "DATA_SOURCE_NAME=${exporter_user}:${exporter_password}@(localhost:3306)/"
        ];
        serviceConfig.ExecStart = ''
          ${pkgs.prometheus-mysqld-exporter}/bin/mysqld_exporter \
             --web.listen-address ${listenAddress}:${toString port} \
             ${concatStringsSep " \\\n  " extraFlags}
        '';
      };
    }
  )

  # Monitor
  (
    let
      prometheusDomain = "prometheus.in.vm";
      prometheusAddr = "127.0.0.1";
      prometheusPort = 9090;
      prometheusBackend = "${prometheusAddr}:${toString prometheusPort}";

      grafanaDomain = "grafana.in.vm";
      grafanaAddr = "127.0.0.1";
      grafanaPort = 9080;
      grafanaBackend = "${grafanaAddr}:${toString grafanaPort}";
      grafanaUser = "admin";
      grafanaPassword = "admin";

      exporters_node_port = 9100;
    in
    {
      services.prometheus = {
        enable = true;
        extraFlags = [ "--web.enable-admin-api" ];
        listenAddress = prometheusAddr;
        port = prometheusPort;

        globalConfig = {
          scrape_interval = "5s";
          evaluation_interval = "5s";
        };

        scrapeConfigs = [
          {
            job_name = "prometheus";
            static_configs = [{ targets = [ prometheusBackend ]; }];
          }

          {
            job_name = "node";
            static_configs = [
              {
                labels = { os = "nixos"; };
                targets = [ "127.0.0.1:${toString exporters_node_port}" ];
              }
              {
                labels = { os = "macos"; };
                targets = [ "${gateway}:${toString exporters_node_port}" ];
              }
            ];
          }

          {
            job_name = "mysql";
            static_configs = [
              {
                labels = { os = "nixos"; };
                targets = [ "127.0.0.1:9104" ];
              }
            ];
          }
        ];
      };

      services.prometheus.exporters.node = {
        enable = true;
        port = exporters_node_port;
      };

      services.grafana = {
        enable = true;
        analytics.reporting.enable = false;
        auth.anonymous.enable = false;
        users.allowSignUp = false;
        users.allowOrgCreate = false;

        domain = grafanaDomain;

        protocol = "http";
        addr = grafanaAddr;
        port = grafanaPort;

        declarativePlugins = with pkgs.grafanaPlugins; [
          grafana-clock-panel
          grafana-piechart-panel
          grafana-polystat-panel
          grafana-worldmap-panel
        ];

        security.adminUser = grafanaUser;
        security.adminPassword = grafanaPassword;
        security.secretKey = "eik2VeeLeehahhoh6xea";
        database.type = "sqlite3";

        provision = {
          enable = true;
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://${prometheusBackend}";
              access = "proxy"; # connect from server side
              isDefault = true;
            }
          ];
        };
      };

      services.caddy.config = mkAfter ''
        http://${prometheusDomain} {
          reverse_proxy ${prometheusBackend}
        }

        http://${grafanaDomain} {
          reverse_proxy ${grafanaBackend}
        }
      '';
    }
  )
]
