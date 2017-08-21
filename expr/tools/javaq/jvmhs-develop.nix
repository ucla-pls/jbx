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
    sha256 = "131m14a5jv0vfypl8q1lpcys9xcfxl7i8rs8xih0gwmc44vz9h0g";
    rev = "ca6b44217075764fade24fbb33c346cdc76af2de";
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
