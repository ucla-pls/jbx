{ stdenv, fetchurl, ant }: java:
stdenv.mkDerivation {
  name = "xalan";
  src = fetchurl {
    url = "http://archive.apache.org/dist/xml/xalan-j/source/xalan-j_2_7_1-src.tar.gz";
    md5 = "fc805051f0fe505c7a4b1b5c8db9b9e3";
  };
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  buildInputs = [ ant java.jdk ];
  buildPhase = ''ant'';
  installPhase = ''
    mkdir -p $out/share/java 
    mv build/xalan.jar $_ 
  '';
}
