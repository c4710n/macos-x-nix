{ lib, stdenv, fetchurl, unzip, undmg }:

let
  _version = "99.0.4844.74";
  _build = "r961656";
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
    sha256 = "sha256:1cg67xdl938ynv2jic13y8ahkcracca5dmrdl7n6yvyqksmjkili";
  };

  meta = with lib; {
    description = "Free and open-source web browser.";
    homepage = "https://chromium.woolyss.com/";
    platforms = platforms.darwin;
  };
}
