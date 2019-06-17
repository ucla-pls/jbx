{ mkDerivation, aeson, base, bytestring, containers, deepseq
, directory, fetchgit, fgl, fgl-visualize, filepath, generic-random
, hpack, hspec-expectations-pretty-diff, jvm-binary, lens
, lens-action, mtl, process, QuickCheck, stdenv, tasty
, tasty-discover, tasty-hspec, tasty-hunit, tasty-quickcheck, text
, vector, zip-archive, src
}:
mkDerivation {
  pname = "jvmhs";
  version = "0.0.1";
  inherit src;
  postUnpack = "sourceRoot+=/jvmhs; echo source root reset to $sourceRoot";
  libraryHaskellDepends = [
    aeson base bytestring containers deepseq directory fgl
    fgl-visualize filepath jvm-binary lens lens-action mtl process text
    vector zip-archive
  ];
  libraryToolDepends = [ hpack ];
  testHaskellDepends = [
    aeson base bytestring containers deepseq directory fgl
    fgl-visualize filepath generic-random 
    hspec-expectations-pretty-diff jvm-binary lens lens-action mtl
    process QuickCheck tasty tasty-discover tasty-hspec tasty-hunit
    tasty-quickcheck text vector zip-archive
  ];
  doHaddock = false;
  doCheck = false;
  preConfigure = "hpack";
  homepage = "https://github.com/ucla-pls/jvmhs#readme";
  description = "A library for reading Java class-files";
  license = stdenv.lib.licenses.mit;
}
