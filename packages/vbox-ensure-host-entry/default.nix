{ pkgs, ... }:

pkgs.writeScriptBin "vbox-ensure-host-entry" (builtins.readFile ./run.sh)
