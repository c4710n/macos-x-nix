{ pkgs, system, ... }:

{
  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs: {
      custom = {
        mg = pkgs.callPackage ./mg { };
        trojan = pkgs.callPackage ./trojan { };
        sarasa-mono-sc-nerd-font = pkgs.callPackage ./sarasa-mono-sc-nerd-font { };
        pragmata-pro-font = pkgs.callPackage ./pragmata-pro-font { };
        macos-chromium = pkgs.callPackage ./macos-chromium { };

        nodePackages = import ./node-packages {
          inherit pkgs system;
        };
      };
    };
  };
}
