{ mkDerivation, base, binary, bytestring, containers, directory
, docopt, either, fetchgit, filepath, lens, mtl, pipes
, pipes-binary, pipes-bytestring, pipes-parse, QuickCheck, stdenv
, transformers, vector, z3
}:
mkDerivation {
  pname = "wiretap-tools";
  version = "0.1.0.0";
  src = fetchgit {
    url = "http://github.com/ucla-pls/wiretap-tools.git";
    sha256 = "0vjr7aa0aq2n1vj4iyivhw98ccvxi0kn7la6vv0vwfn46nrq026s";
    rev = "c37717f1fe30ccd2ed36de87c61b0f709fb547e8";
  };
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base binary bytestring containers directory docopt either filepath
    lens mtl pipes pipes-binary pipes-bytestring pipes-parse QuickCheck
    transformers vector z3
  ];
  description = "Tools for analysing the output of Wiretap";
  license = stdenv.lib.licenses.gpl3;
}
