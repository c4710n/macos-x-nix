{ lib, stdenv, fetchFromGitHub, cmake, boost, openssl, libmysql, ... }:

stdenv.mkDerivation rec {
  pname = "trojan";
  version = "1.14.1";

  # Git tag includes CMake build files which are much more convenient.
  src = fetchFromGitHub {
    owner = "trojan-gfw";
    repo = "trojan";
    rev = "refs/tags/v${version}";
    sha256 = "1d35yzyckdvff74wmlsm9hqghnsv0lcclqqwqbyafz7b8hi7yw8d";
  };

  nativeBuildInputs = [ cmake boost openssl libmysql ];
  cmakeFlags = [
    "-DMYSQL_INCLUDE_DIR=${libmysql.dev}/include/mysql"
    "-DMYSQL_LIBRARIES=${libmysql}/lib/mysql"
  ];

  meta = with lib; {
    description = "An unidentifiable mechanism that helps you bypass GFW.";
    homepage = "https://github.com/trojan-gfw/trojan";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
