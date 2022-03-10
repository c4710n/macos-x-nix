{ pkgs, ... }:

pkgs.writeScriptBin "ensure-vbox-headless-run" (builtins.readFile ./run.sh)
