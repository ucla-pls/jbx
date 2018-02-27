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
    sha256 = "0rpdp98b0d1jf3yrar319ciyq3bd98ja80w6m4pb4igp2w7jnqyi";
    rev = "ba497c57f87fecceda36be7c13bfe929bb3db8dc";
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
