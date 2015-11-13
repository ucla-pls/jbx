{ stdenv, fetchurl }:
let 
logicblox3 = stdenv.mkDerivation {
  name = "logicblox";
  version = "3.10.21";
  src = ./logicblox.tar.gz;
  buildPhase = "";
  installPhase = ''
    mkdir $out
    cp -r * $out
  '';
};
logicblox4 = stdenv.mkDerivation {
  name = "logicblox";
  version = "4.2.0";
  src = ./logicblox-4.2.0.tar.gz;
  buildPhase = "";
  installPhase = ''
    mkdir $out
    cp -r * $out
  '';
};
in logicblox4
