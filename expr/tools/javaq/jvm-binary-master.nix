{ mkDerivation, attoparsec, base, binary, bytestring, containers
, criterion, data-binary-ieee754, deepseq, deriving-compat
, directory, fetchgit, filepath, generic-random, hpack
, hspec-expectations-pretty-diff, mtl, QuickCheck, stdenv, tasty
, tasty-discover, tasty-hspec, tasty-quickcheck, template-haskell
, text, vector
}:
mkDerivation {
  pname = "jvm-binary";
  version = "0.4.0";
  src = fetchgit {
    url = "https://github.com/ucla-pls/jvm-binary.git";
    sha256 = "1m78z89lm730fh9vcjn7972aijbx0bhz474w2nzm6kzwdf9cp2w0";
    rev = "c8088e8a43b24edd65f63686569a5182927d2866";
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
