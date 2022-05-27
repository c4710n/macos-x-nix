{ pkgs, username, ... }:
let
  globalNPMConfigFile = ".npm/global-npmrc";
in
{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      custom.nodePackages.pnpm
      yarn
      nodejs-16_x
    ];

    programs.bash.shellAliases = {
      # show v8 version
      node-v8-version = "node -e 'console.log(process.versions.v8)'";

      # disable emoji for yarn
      yarn = "yarn --emoji false";
    };

    programs.bash.initExtra = ''
      ## NPM ##
      export NPM_CONFIG_GLOBALCONFIG=$HOME/${globalNPMConfigFile}
    '';

    home.file."${globalNPMConfigFile}".text = ''
      tag-version-prefix=
    '';
  };
}
