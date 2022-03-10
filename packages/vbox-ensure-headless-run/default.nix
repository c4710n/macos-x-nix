{ pkgs, ... }:

pkgs.writeScriptBin "vbox-ensure-headless-run" (builtins.readFile ./run.sh)
