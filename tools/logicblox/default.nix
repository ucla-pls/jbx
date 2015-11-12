{ stdenv, fetchurl }:
stdenv.mkDerivation {
  name = "logicblox";
  version = "3.10.21";
  src = ./logicblox.tar.gz;
  buildPhase = "";
  installPhase = ''
    mkdir $out
    cp -r * $out
  '';
}
