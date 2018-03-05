{ mkDerivation, base, binary, bytestring, containers, directory
, docopt, either, fetchgit, filepath, lens, mtl, pipes
, pipes-binary, pipes-bytestring, pipes-parse, QuickCheck, stdenv
, transformers, vector, z3, fgl
}:
mkDerivation {
  pname = "wiretap-tools";
  version = "0.1.0.0";
  src = fetchgit {
    url = "http://github.com/ucla-pls/wiretap-tools.git";
    sha256 = "05vsxmbclds05jrkgbpcccv67q1hx9amasnhsbc2kiccjadwx9g2";
    rev = "bea1e71777be4e4dfca8dfbee9001f9c967b0194";
  };
  # patches = [ ./hotfix.patch ];
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [
    base binary bytestring containers directory docopt either filepath
    lens mtl pipes pipes-binary pipes-bytestring pipes-parse QuickCheck
    transformers vector z3 fgl
  ];
  description = "Tools for analysing the output of Wiretap";
  license = stdenv.lib.licenses.gpl3;
}
