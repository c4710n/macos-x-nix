{ pkgs, ... }:

pkgs.writeScriptBin "mg" ''
  #!${pkgs.stdenv.shell}
  exec ${pkgs.mg}/bin/mg -n $@
''
