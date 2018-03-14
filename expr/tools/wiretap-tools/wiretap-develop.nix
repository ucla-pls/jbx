{ mkDerivation, base, binary, bytestring, containers, directory
, docopt, either, fetchgit, filepath, lens, mtl, pipes
, pipes-binary, pipes-bytestring, pipes-parse, QuickCheck, stdenv
, transformers, vector, z3, fgl, hspec
}:
mkDerivation {
  pname = "wiretap-tools";
  version = "0.1.0.0";
  src = fetchgit {
    url = "http://github.com/ucla-pls/wiretap-tools.git";
    sha256 = "1mpj7rlvx2wq74006qslix88cz02wzw9mlvklchj6zx5isj81xiv";
    rev = "57f7cb411a73d06085fecc0d1e2129d19e534bf5";
  };
  # patches = [ ./hotfix.patch ];
  isLibrary = true;
  isExecutable = true;
  executableHaskellDepends = [
    base binary bytestring containers directory docopt either filepath
    lens mtl pipes pipes-binary pipes-bytestring pipes-parse QuickCheck
    transformers vector z3 fgl hspec
  ];
  description = "Tools for analysing the output of Wiretap";
  license = stdenv.lib.licenses.gpl3;
}
