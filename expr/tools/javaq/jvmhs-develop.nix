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
    sha256 = "05gzgh19brhyysx33kv7syk2shh62zv2nmzrah4j7kbd64dmd5hp";
    rev = "7a6dc1691b9e9d277697439d36fe10969ef8277f";
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
