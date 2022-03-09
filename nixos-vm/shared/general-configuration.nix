{ hostName, ip, secrets, ... }:

{ pkgs, ... }: {
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.enableIPv6 = false;
  # enp0s3 is the interface for NAT.
  networking.interfaces.enp0s3.useDHCP = true;
  # enp0s8 is the interface for Host-only network.
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
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  environment.systemPackages = with pkgs; [
    mg
    btop
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
  };

  # Setup users
  users.users.root = {
    password = "nixos";
    openssh.authorizedKeys.keys = [ secrets.nixos-vm-ssh-key-public ];
  };

  networking.hostName = hostName;
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
