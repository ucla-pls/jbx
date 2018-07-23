{ mkDerivation, aeson, base, binary, bytestring, containers
, directory, docopt, fetchgit, filepath, free, lens, process
, stdenv, tasty, tasty-discover, tasty-hspec, tasty-quickcheck
, text, vector, zip-archive
}:
mkDerivation {
  pname = "jvmhs";
  version = "0.1.0.0";
  src = fetchgit {
    url = "https://github.com/ucla-pls/jvmhs.git";
    sha256 = "1y2gg2kimk1jiyg6fqc9wg0mlw7ghbxiwgv4k19d9f9gj312gl8k";
    rev = "e72c01d760fd790b591a292b2c4e30c48c1e0b1c";
  };
  isLibrary = true;
  isExecutable = true;
  libraryHaskellDepends = [
    aeson base binary bytestring containers directory filepath free
    lens process text vector zip-archive
  ];
  executableHaskellDepends = [
    aeson base bytestring containers docopt lens text
  ];
  testHaskellDepends = [
    base binary bytestring containers directory filepath process tasty
    tasty-discover tasty-hspec tasty-quickcheck vector
  ];
  doCheck = false;
  homepage = "https://github.com/kalhauge/jvmhs#readme";
  license = stdenv.lib.licenses.bsd3;
}
