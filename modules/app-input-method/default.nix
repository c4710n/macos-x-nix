{ username, homeDir, ... }:
let
  path = "Library/Rime";
in
{
  homebrew.casks = [ "squirrel" ];

  home-manager.users."${username}" = {
    home.file."${path}/default.custom.yaml".source =
      ./files/default.custom.yaml;
    home.file."${path}/squirrel.custom.yaml".source =
      ./files/squirrel.custom.yaml;
    home.file."${path}/luna_pinyin_simp.schema.custom.yaml".source =
      ./files/luna_pinyin_simp.schema.custom.yaml;
  };

  system.activationScripts.extraActivation.text = ''
    echo "[RIME] cleaning ~/${path}/build ..."
    rm -rf ${homeDir}/${path}/build
  '';
}
