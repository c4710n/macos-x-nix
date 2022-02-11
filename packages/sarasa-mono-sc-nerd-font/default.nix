{ lib, stdenv, fetchurl, unzip, ... }:

stdenv.mkDerivation rec {
  pname = "sarasa-mono-sc-nerd-font";
  version = "1.0.0";

  src = fetchurl {
    url =
      "https://github.com/laishulu/Sarasa-Mono-SC-Nerd/archive/v${version}.zip";
    sha256 = "0ixjqxf707mvngvrynf6qd4245456ns135kb28c8q8405fybxwaq";
  };

  nativeBuildInputs = [ unzip ];

  phases = "unpackPhase installPhase";

  unpackPhase = ''
    unzip $src
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/sarasa-mono-sc-nerd-font
    cp -r Sarasa-Mono-SC-Nerd-${version}/*.ttf $out/share/fonts/sarasa-mono-sc-nerd-font
  '';

  meta = with lib; {
    description = "Sarasa Mono SC patched with nerd-fonts.";
    platforms = platforms.all;
  };
}
