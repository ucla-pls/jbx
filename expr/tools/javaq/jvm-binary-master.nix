{ mkDerivation, attoparsec, base, binary, bytestring, containers
, criterion, data-binary-ieee754, deepseq, deriving-compat
, directory, fetchgit, filepath, generic-random, hpack
, hspec-expectations-pretty-diff, mtl, QuickCheck, stdenv, tasty
, tasty-discover, tasty-hspec, tasty-quickcheck, template-haskell
, text, vector
}:
mkDerivation {
  pname = "jvm-binary";
  version = "0.1.0";
  src = fetchgit {
    url = "https://github.com/ucla-pls/jvm-binary.git";
    sha256 = "1f5bb6f75j49jlqi3q82fwrvips1l8lrkkcxbglik9qryxcrj161";
    rev = "1180eb89365fcac7d7a0a71fa906cea3c63a05de";
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
