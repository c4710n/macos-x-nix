{ lib, stdenv, fetchurl, unzip, undmg }:

let
  _version = "103.0.5060.53";
  _build = "r1002911";
in
stdenv.mkDerivation rec {
  pname = "chromium";
  version = "${_version}-${_build}";

  buildInputs = [ unzip ];
  sourceRoot = ".";
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p "$out/Applications"
    cp -r "Chromium.app" "$out/Applications/Chromium.app"
  '';

  src = fetchurl {
    url =
      "https://github.com/macchrome/macstable/releases/download/v${_version}-${_build}-Ungoogled-macOS/Chromium.app.ungoogled-${_version}.zip";
    sha256 = "sha256-6Ug0SzcRg/P1oFfikQEPYV9Nn6hiCTJAKRVw+ejkUZI=";
  };

  meta = with lib; {
    description = "Free and open-source web browser.";
    homepage = "https://chromium.woolyss.com/";
    platforms = platforms.darwin;
  };
}
