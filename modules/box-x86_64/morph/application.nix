{ config, pkgs, lib, secrets, ... }:

with lib;

lib.mkMerge [
  # Docker
  (
    let
      port = 2375;
    in
    {
      virtualisation.docker = {
        enable = true;
        enableOnBoot = true;
        storageDriver = "overlay2";
        logDriver = "journald";
        autoPrune = {
          enable = true;
          flags = [ "--all" ];
          dates = "weekly";
        };
        liveRestore = true;
        listenOptions = [
          "0.0.0.0:2375"
          "/run/docker.sock"
        ];
        extraOptions = "--insecure-registry=${secrets.insecure-registry}";
      };
      networking.firewall.allowedTCPPorts = [ port ];
    }
  )

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
        # allow all connections. Because I have firewall, so this is fine.
        host all all 0.0.0.0/0 md5
      '';
    };

    networking.firewall.allowedTCPPorts = [ config.services.postgresql.port ];
  }

  # Redis
  {
    services.redis.servers.general = {
      enable = true;
      bind = "0.0.0.0";
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

            max_connections = 250;
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
]
