{ pkgs, ... }:

pkgs.writeScriptBin "ensure-vbox-host-entry" (builtins.readFile ./run.sh)
