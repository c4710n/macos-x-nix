{ lib, stdenv, fetchurl, unzip, undmg }:

let
  _version = "100.0.4896.75";
  _build = "r972766";
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
    sha256 = "sha256:16i2y0xsn20rljlwg9y4kpbbwsvnyz3fkvw1ynclg9jiwgjhjnzc";
  };

  meta = with lib; {
    description = "Free and open-source web browser.";
    homepage = "https://chromium.woolyss.com/";
    platforms = platforms.darwin;
  };
}
