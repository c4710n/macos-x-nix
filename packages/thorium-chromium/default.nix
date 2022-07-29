{ lib, stdenv, fetchurl, undmg }:

let
  _version = "105.0.5194.0";
in
stdenv.mkDerivation rec {
  pname = "chromium";
  version = "${_version}";

  buildInputs = [ undmg ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p "$out/Applications"
    cp -r "Thorium.app" "$out/Applications/Thorium.app"
  '';

  src = fetchurl {
    url = "https://github.com/Alex313031/Thorium-Special/releases/download/M${_version}/Thorium_MacOS_${_version}_ARM64.dmg";
    sha256 = "sha256-zc7ULx6GOewEERapWJuNquG1f7GDd4Jwz+csV5YioPc=";
  };

  meta = with lib; {
    description = "Builds of Thorium for MacOS, different processors and NEW Raspberry Pi ARM64 builds.";
    homepage = "https://github.com/Alex313031/Thorium-Special";
    platforms = platforms.aarch64;
  };
}
