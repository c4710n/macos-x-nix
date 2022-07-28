{ pkgs, lib, username, ... }:

lib.mkMerge [
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        cmake
      ];
    };
  }

  # system monitoring
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        htop
      ];
    };

    homebrew.brews = [ "btop" ];

    homebrew.casks = [ "sloth" ];
  }

  # performance analyzing
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        # most of the time, use speedscope
        custom.nodePackages.speedscope

        # when the file is too large to load in speedscope, use flamegraph
        flamegraph
      ];
    };
  }

  # font processing
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        python39Packages.fonttools
        fontforge
      ];
    };
  }

  # load testing
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        wrk
        tsung
      ];
    };
  }

  # web development
  {
    homebrew.casks = [
      # color picker
      "pika"

      # better browser for developing web page
      # "sizzy" - currently, sizzy's download link is broken.
    ];
  }

  # DNS
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [ dogdns ];
    };
  }

  # request tools
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        curl
        wget
        aria
      ];

      programs.bash.shellAliases = {
        # https://susam.in/maze/timing-with-curl.html
        # + time_namelookup: The time, in seconds, it took from the start until the name resolving was completed.
        # + time_connect: The time, in seconds, it took from the start until the TCP connect to the remote host (or proxy) was completed.
        # + time_appconnect: The time, in seconds, it took from the start until the SSL/SSH/etc connect/handshake to the remote host was completed. (Added in 7.19.0)
        # + time_pretransfer: The time, in seconds, it took from the start until the file transfer was just about to begin. This includes all pre-transfer commands and negotiations that are specific to the particular protocol(s) involved.
        # + time_redirect: The time, in seconds, it took for all redirection steps include name lookup, connect, pretransfer and transfer before the final transaction was started. time_redirect shows the complete execution time for multiple redirections. (Added in 7.12.3)
        # + time_starttransfer: The time, in seconds, it took from the start until the first byte was just about to be transferred. This includes time_pretransfer and also the time the server needed to calculate the result.
        # + time_total: The total time, in seconds, that the full operation lasted. The time will be displayed with millisecond resolution.
        ",curl" = ''curl -w "time_namelookup: %{time_namelookup}\ntime_connect: %{time_connect}\ntime_appconnect: %{time_appconnect}\ntime_pretransfer: %{time_pretransfer}\ntime_redirect: %{time_redirect}\ntime_starttransfer: %{time_starttransfer}\ntime_total: %{time_total}\n"'';
      };
    };
  }

  # tunnel
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        frp
        v2ray
        wireguard-tools
      ];
    };

    homebrew.masApps = {
      WireGuard = 1451685025;
    };
  }

  # local web server
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        caddy
      ];

      programs.bash.shellAliases = {
        ",serve" = "${pkgs.python3}/bin/python3 -m http.server";
      };
    };
  }

  # database
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        postgresql_14
        mysql80
        redis

        pgcli
        mycli
      ];
    };

    homebrew.casks = [
      "tableplus"
    ];
  }
]
