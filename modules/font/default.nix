{ pkgs, ... }:

{
  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      custom.pragmata-pro-font
      custom.sarasa-mono-sc-nerd-font
    ];
  };
}
