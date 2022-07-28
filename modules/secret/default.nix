{ pkgs, lib, username, homeDir, ... }:

lib.mkMerge [
  # GPG
  {
    home-manager.users."${username}" = {
      programs.gpg = {
        enable = true;
        homedir = "${homeDir}/.gnupg";
        settings = {
          # when outpputting certificates, view user IDs distinctly from keys
          "fixed-list-mode" = true;

          # long keyids are more collision-resistant than short keyids
          # it's trivial to make a key with any desired short keyid
          "keyid-format" = "0xlong";
        };
      };

      home.packages = with pkgs; [
        paperkey
      ];
    };
  }

  # Password
  {
    home-manager.users."${username}" = {
      # password generator
      home.packages = with pkgs; [
        pwgen
      ];

      # password manager
      programs.password-store = {
        enable = true;
        package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
      };

      programs.bash.initExtra = ''
        ## PASSWORD STORE ##
        export PASSWORD_STORE_DIR=$HOME/.local/share/password-store
        export PASSWORD_STORE_CLIP_TIME=10
      '';
    };
  }

  # SSH
  {
    home-manager.users."${username}" = {
      home.packages = with pkgs; [
        keychain
      ];

      programs.bash.initExtra = (builtins.readFile ./files/ssh.sh);
    };
  }
]
