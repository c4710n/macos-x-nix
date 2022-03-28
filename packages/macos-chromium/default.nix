{ lib, stdenv, fetchurl, unzip, undmg }:

let
  _version = "99.0.4844.84";
  _build = "r1060";
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
    sha256 = "sha256:1jsa6ga3j8adk4m0qx56xarza1x5ghxgrb8w9c1si9zhviav9j8a";
  };

  meta = with lib; {
    description = "Free and open-source web browser.";
    homepage = "https://chromium.woolyss.com/";
    platforms = platforms.darwin;
  };
}
