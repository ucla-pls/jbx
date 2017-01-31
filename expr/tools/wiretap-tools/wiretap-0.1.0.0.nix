{ mkDerivation, base, binary, bytestring, containers, directory
, docopt, fetchgit, filepath, lens, mtl, pipes, pipes-binary
, pipes-bytestring, pipes-parse, QuickCheck, stdenv, vector, z3
}:
mkDerivation {
  pname = "wiretap-tools";
  version = "0.1.0.0";
  src = fetchgit {
    url = "http://github.com/ucla-pls/wiretap-tools.git";
    sha256 = "0p9c44iyfk8sc83p26wriv50kgrymrp101syk2vw9crv3zci097l";
    rev = "2750b4abe15187ddd095a7dbbf6c050cfcde559a";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base binary bytestring containers directory docopt filepath lens
    mtl pipes pipes-binary pipes-bytestring pipes-parse QuickCheck
    vector z3
  ];
  description = "Tools for analysing the output of Wiretap";
  license = stdenv.lib.licenses.gpl3;
}
