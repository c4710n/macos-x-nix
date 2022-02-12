{ pkgs, username, ... }:

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
