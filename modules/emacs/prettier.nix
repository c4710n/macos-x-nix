{ pkgs, username, ... }:

{
  home-manager.users."${username}" = {
    home.packages = with pkgs; [
      nodePackages.prettier
    ];

    home.file.".prettierrc.yml".text = ''
      singleQuote: true
      trailingComma: es5
      semi: false
    '';

    programs.bash.initExtra = ''
      # When using nix-shell environment installed a standalone nodejs, add following
      # line to shellHook:
      #
      #   export NODE_PATH=${pkgs.nodePackages.prettier}/lib/node_modules:$NODE_PATH
      #
      export PRETTIER_NODE_PATH="${pkgs.nodePackages.prettier}/lib/node_modules"
      export NODE_PATH="$PRETTIER_NODE_PATH:$NODE_PATH"
    '';
  };
}
