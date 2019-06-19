{ mkDerivation, base, binary, bytestring, containers, directory
, filepath, hpack, mtl, stdenv, text, transformers, vector
, src
}:
mkDerivation {
  pname = "wiretap-pointsto";
  version = "0.1.0.0";
  src = src;
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base binary bytestring containers directory filepath mtl text
    transformers vector
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    base binary bytestring containers directory filepath mtl text
    transformers vector
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/ucla-pls/wiretap-pointsto#readme";
  license = stdenv.lib.licenses.bsd3;
}
