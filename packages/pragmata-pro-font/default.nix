{ lib, stdenv, fetchurl, unzip, ... }:

stdenv.mkDerivation rec {
  pname = "pragmata-pro-font";
  version = "0.829";

  src = ./PragmataPro0.829-ptikme.zip;

  nativeBuildInputs = [ unzip ];

  phases = "unpackPhase installPhase";

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/${pname}
    cp -r PragmataPro${version}/*.ttf $out/share/fonts/${pname}
  '';

  meta = with lib; {
    description = "PragmataPro™ is a condensed monospaced font optimized for screen, designed by Fabrizio Schiavi to be the ideal font for coding, math and engineering.";
    platforms = platforms.all;
  };
}
