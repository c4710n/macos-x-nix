{ lib, stdenv, fetchurl, unzip, undmg }:

let
  _version = "95.0.4638.69";
  _build = "r920003";
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
    sha256 = "03y4s22xbygxcacvk331h0pg3jwvw5927k9sqi64xkk1ski8ijr2";
  };

  meta = with lib; {
    description = "Free and open-source web browser.";
    # ungoogled
    # widevine
    # all-codecs+
    # no-sync
    homepage = "https://chromium.woolyss.com/";
    platforms = platforms.darwin;
  };
}
