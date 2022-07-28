{ username, ... }:

{
  # 1. enable lorri daemon service
  services.lorri.enable = true;

  home-manager.users."${username}" = {
    programs.direnv = {
      # 2. install direnv
      enable = true;

      # 3. setup direnv hook for shell
      enableBashIntegration = true;

      # It doesn't need to use `nix-direnv` anymore, because `lorri` and `nix-direnv`
      # are the same type of tools - integrating Direnv with Nix.
      nix-direnv.enable = false;
    };
  };
}
