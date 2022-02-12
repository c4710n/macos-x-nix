{ pkgs, username, ... }:
let
  globalNPMConfigFile = ".npm/global-npmrc";
in
{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [ nodejs-16_x yarn ];

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
