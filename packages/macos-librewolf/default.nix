{ lib, stdenv, fetchurl, unzip, undmg }:

let
  _version = "97.0.1";
  _build = "1";
in
stdenv.mkDerivation rec {
  pname = "librewolf";
  version = "${_version}-${_build}";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p "$out/Applications"
    cp -r "LibreWolf.app" "$out/Applications/LibreWolf.app"
  '';

  src = fetchurl {
    url = "https://gitlab.com/librewolf-community/browser/macos/uploads/d6906f34d5b20b5ca889d7062378d9b6/librewolf-${version}.en-US.mac.x86_64.dmg";
    sha256 = "0rwwnrairmbhgh36mpch1s5cpkmf6775r5nvc3xrxq2jd0k3j9ds";
  };

  meta = with lib; {
    description = "A fork of Firefox, focused on privacy, security and freedom.";
    homepage = "https://librewolf.net/";
    platforms = platforms.darwin;
  };
}
