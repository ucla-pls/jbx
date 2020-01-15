{ mkDerivation, base, binary, bytestring, containers, directory
, docopt, either, exceptions, fetchgit, fgl, filepath, hpack, hspec
, lens, mtl, pipes, pipes-binary, pipes-bytestring, pipes-parse
, QuickCheck, stdenv, transformers, vector, z3
}:
mkDerivation {
  pname = "wiretap-tools";
  version = "0.1.0.0";
  src = fetchgit {
    url = "http://github.com/ucla-pls/wiretap-tools.git";
    sha256 = "0maa6n0rbwjhhc9fxg4vqprza9grpq3xs6vmycn1wavl63wkyrzl";
    rev = "effb0e2960f01360357268231154243536c10799";
    fetchSubmodules = true;
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    base binary bytestring containers directory docopt either
    exceptions fgl filepath lens mtl pipes pipes-binary
    pipes-bytestring pipes-parse QuickCheck transformers vector z3
  ];
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    base binary bytestring containers directory docopt either
    exceptions fgl filepath lens mtl pipes pipes-binary
    pipes-bytestring pipes-parse QuickCheck transformers vector z3
  ];
  testHaskellDepends = [
    base binary bytestring containers directory docopt either
    exceptions fgl filepath hspec lens mtl pipes pipes-binary
    pipes-bytestring pipes-parse QuickCheck transformers vector z3
  ];
  benchmarkHaskellDepends = [
    base binary bytestring containers directory docopt either
    exceptions fgl filepath lens mtl pipes pipes-binary
    pipes-bytestring pipes-parse QuickCheck transformers vector z3
  ];
  prePatch = "hpack";
  description = "Tools for analysing the output of Wiretap";
  license = stdenv.lib.licenses.gpl3;
}
