{ pkgs, hostConfig, ... }:

let
  networkName = "Wi-Fi";
  port-dnsmasq = 53;
  port-dnscrypt-proxy = 1053;
in
{
  networking = {
    computerName = hostConfig.computerName;
    hostName = hostConfig.hostName;
  };

  system.activationScripts.extraActivation.text = ''
    CURRENT_DNS=$(networksetup -getdnsservers "${networkName}")
    LOCAL_DNS="127.0.0.1"
    ENHANCED_MODE_DNS="198.18.0.2"

    if [ "$CURRENT_DNS" != "$LOCAL_DNS" ] && [ "$CURRENT_DNS" != "$ENHANCED_MODE_DNS" ]; then
        echo "setting DNS as $LOCAL_DNS"
        networksetup -setdnsservers ${networkName} $LOCAL_DNS
    else
        echo "skipping DNS setting..."
    fi
  '';

  launchd.daemons.dnsmasq =
    let
      command = "${pkgs.dnsmasq}/bin/dnsmasq";
      configFile = toString
        (pkgs.writeText "dnsmasq.conf" ''
          listen-address=127.0.0.1
          port=${toString port-dnsmasq}

          ## ignore configured name servers located in resolv.conf
          no-resolv
          no-poll

          ## send queries to the upstearm servers in strict order
          strict-order

          ##list of domains that will be redirected
          # redirect *.dev.local to 127.0.0.1
          address=/dev.local/127.0.0.1

          ## forward all dns requests to the dnscrypt-proxy
          server=127.0.0.1#${toString port-dnscrypt-proxy}

          ## debug
          # log-queries
        '');
      args = "--keep-in-foreground -C ${configFile}";
    in
    {
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive = true;
      serviceConfig.ProgramArguments = [
        "/bin/sh"
        "-c"
        "/bin/wait4path ${command} && exec ${command} ${args}"
      ];
    };

  launchd.daemons.dnscrypt-proxy =
    let
      command = "${pkgs.dnscrypt-proxy2}/bin/dnscrypt-proxy";
      configFile = toString
        (pkgs.writeText "dnscrypt-proxy.toml" ''
          listen_addresses = ["127.0.0.1:${toString port-dnscrypt-proxy}"]

          cache = true
          doh_servers = true
          fallback_resolvers = ["223.5.5.5:53", "223.6.6.6:53"]
          ignore_system_dns = true
          netprobe_address = "223.5.5.5:53"
          netprobe_timeout = 30

          [static]

          # The sdns:// address is called DNS Stamp.
          # It encode all the parameters required to connect to a secure DNS server as a single string.
          #
          #   + https://dnscrypt.info/stamps-specifications/
          #   + https://dnscrypt.info/stamps
          #
          [static.containerpi]
          stamp = "sdns://AgMAAAAAAAAADDQ1Ljc3LjE4MC4xMCBsA2QQ3lR1Nl9Ygfr8FdBIpL-doxmHECRx3T5NIXYYtxNkbnMuY29udGFpbmVycGkuY29tCi9kbnMtcXVlcnk"

          [static.geekdns-doh]
          stamp = "sdns://AgcAAAAAAAAAACCi3jNJDEdtNW4tvHN8J3lpIklSa2Wrj7qaNCgEgci9_AtpLjIzM3B5LmNvbQovZG5zLXF1ZXJ5"

          [static.rubyfish]
          stamp = "sdns://AgUAAAAAAAAAACA-GhoPbFPz6XpJLVcIS1uYBwWe4FerFQWHb9g_2j24OA9kbnMucnVieWZpc2guY24KL2Rucy1xdWVyeQ"

          [static.rubyfish-ea]
          stamp = "sdns://AgUAAAAAAAAAACA-GhoPbFPz6XpJLVcIS1uYBwWe4FerFQWHb9g_2j24OBJlYS1kbnMucnVieWZpc2guY24KL2Rucy1xdWVyeQ"

          [static.rubyfish-uw]
          stamp = "sdns://AgUAAAAAAAAAACA-GhoPbFPz6XpJLVcIS1uYBwWe4FerFQWHb9g_2j24OBJ1dy1kbnMucnVieWZpc2guY24KL2Rucy1xdWVyeQ"
        '');
      args = "-config ${configFile}";
    in
    {
      serviceConfig.RunAtLoad = true;
      serviceConfig.KeepAlive = true;
      serviceConfig.ProgramArguments = [
        "/bin/sh"
        "-c"
        "/bin/wait4path ${command} && exec ${command} ${args}"
      ];
    };
}
