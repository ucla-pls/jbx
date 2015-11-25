{ stdenv, fetchurl }: java:
stdenv.mkDerivation {
  name = "xerces";
  version = "2.8.0";
  src = fetchurl {
    url = "http://archive.apache.org/dist/xml/xerces-j/binaries/Xerces-J-bin.2.8.0.tar.gz";
    md5 = "16f148b4a9551cf47bc961c5cec84041";
  };
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p $out/share/java/
    mv *.jar $_ 
  '';
}
