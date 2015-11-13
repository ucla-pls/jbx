{ stdenv }:
let 
logicblox3 = stdenv.mkDerivation {
  name = "logicblox";
  version = "3.10.21";
  src = ./logicblox-3.10.21.tar.gz;
  buildPhase = "";
  installPhase = "
    mkdir $out
    cp -r logicblox/* $out
  ";
};
logicblox4 = stdenv.mkDerivation {
  name = "logicblox";
  version = "4.2.0";
  src = ./logicblox-4.2.0.tar.gz;
  buildPhase = "";
  installPhase = " 
    mkdir $out
    cp -r * $out
  ";
};
in { inherit logicblox4 logicblox3; }
