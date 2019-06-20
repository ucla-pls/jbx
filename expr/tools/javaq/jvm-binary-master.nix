{ mkDerivation, attoparsec, base, binary, bytestring, containers
, criterion, data-binary-ieee754, deepseq, deriving-compat
, directory, fetchgit, filepath, generic-random, hpack
, hspec-expectations-pretty-diff, mtl, QuickCheck, stdenv, tasty
, tasty-discover, tasty-hspec, tasty-quickcheck, template-haskell
, text, vector
}:
mkDerivation {
  pname = "jvm-binary";
  version = "0.5.0";
  src = fetchgit {
    url = "https://github.com/ucla-pls/jvm-binary.git";
    sha256 = "0m5apwxcbx2k4781i39dhvq2xyl0w67j7z72xcig532nyr7gimli";
    rev = "638b6f0ca4cb609a30af140f27f9db998af1622e";
  };
  libraryHaskellDepends = [
    attoparsec base binary bytestring containers data-binary-ieee754
    deepseq deriving-compat mtl template-haskell text vector
  ];
  libraryToolDepends = [ hpack ];
  testHaskellDepends = [
    attoparsec base binary bytestring containers data-binary-ieee754
    deepseq deriving-compat directory filepath generic-random
    hspec-expectations-pretty-diff mtl QuickCheck tasty tasty-discover
    tasty-hspec tasty-quickcheck template-haskell text vector
  ];
  doHaddock = false;
  doCheck = false;
  preConfigure = "hpack";
  homepage = "https://github.com/ucla-pls/jvm-binary#readme";
  description = "A library for reading Java class-files";
  license = stdenv.lib.licenses.mit;
}
