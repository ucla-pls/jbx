{ mkDerivation, aeson, base, base16-bytestring, bytestring
, containers, cryptohash-sha256, deepseq, docopt, fetchgit
, filepath, hpack, jvmhs, lens, lens-action, stdenv, text, src
, cassava, ansi-wl-pprint, hexstring, optparse-applicative
}:
mkDerivation {
  pname = "javaq";
  version = "0.1.0";
  inherit src;
  postUnpack = "sourceRoot+=/javaq; echo source root reset to $sourceRoot";
  isLibrary = false;
  isExecutable = true;
  libraryToolDepends = [ hpack ];
  executableHaskellDepends = [
    aeson base base16-bytestring bytestring containers
    cryptohash-sha256 deepseq docopt filepath jvmhs lens lens-action
    text
    cassava ansi-wl-pprint hexstring optparse-applicative
  ];
  preConfigure = "hpack";
  homepage = "https://github.com/ucla-pls/jvmhs#readme";
  description = "A library for reading Java class-files";
  license = stdenv.lib.licenses.mit;
}
