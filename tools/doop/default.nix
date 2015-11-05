{stdenv, fetchurl, logicblox}:
stdenv.mkDerivation {
  name = "doop";
  version = "r160113";
  src = fetchurl {
    url = "http://doop.program-analysis.org/software/doop-r160113-bin.tar.gz";
    md5 = "90b14b77b818f149e77406d17a9751c3";
  };
}
