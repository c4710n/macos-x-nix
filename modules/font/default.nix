{ pkgs, ... }:

{
  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      custom.pragmata-pro-font
      custom.sarasa-mono-sc-nerd-font
    ];
  };
}
