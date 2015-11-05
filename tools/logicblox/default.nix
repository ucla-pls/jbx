{ stdenv }:
stdenv.mkDerivation {
  name = "logicblox";
  version = "0";
  src = ./logicblox.tar.gz;
  buildPhase = "";
  installPhase = ''
    mkdir $out
    cp -r * $out
  '';
}
