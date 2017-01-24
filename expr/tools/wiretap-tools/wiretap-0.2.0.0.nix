{ mkDerivation, base, binary, bytestring, containers, directory
, docopt, either, fetchgit, filepath, lens, mtl, pipes
, pipes-binary, pipes-bytestring, pipes-parse, QuickCheck, stdenv
, transformers, vector, z3
}:
mkDerivation {
  pname = "wiretap-tools";
  version = "0.2.0.0";
  src = fetchgit {
    url = "http://github.com/ucla-pls/wiretap-tools.git";
    sha256 = "1syy0slnrqjldy98vbr4k0m3kiza54wxh3aywaaa1fqzpjz93vaj";
    rev = "573ba05cec9cb698910868864c6dcb5736361cb2";
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
