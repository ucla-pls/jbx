{ stdenv, fetchurl }: java:
stdenv.mkDerivation {
  name = "derby";
  version = "10.5.3.0";
  src = fetchurl {
    url = "http://archive.apache.org/dist/db/derby/db-derby-10.5.3.0/db-derby-10.5.3.0-bin.tar.gz";
    md5 = "35367c636ce035102a039a19ca707986";
  };
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p $out/share/java
    find . -name "*.jar" -exec cp {} $_ \;
  '';
}