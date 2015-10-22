{ stdenv, fetchurl, ant }:
stdenv.mkDerivation {
  name = "OpenJDK6";
  version = "b36";
  src = fetchurl {
    url = https://java.net/projects/openjdk6/downloads/download/openjdk-6-src-b36-22_jul_2015.tar.xz;
    sha256 = "1x16vznfqrb2a1l0c55xjy523czplb6aqc60axgizdmk13927py9";
  };
  unpackPhase=''
    tar xf --one-top-level=jdk6 $src
    sourceRoot=jdk6
  '';
  buildInputs = [ ant ];
}
