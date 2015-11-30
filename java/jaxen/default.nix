{ stdenv, fetchurl, ant }: java:
stdenv.mkDerivation {
  name = "jaxen";
  version = "2.8.0";
  src = fetchurl {
    url = "http://pkgs.fedoraproject.org/repo/pkgs/jaxen/jaxen-1.1.1-src.tar.gz/b598ae6b7e765a92e13667b0a80392f4/jaxen-1.1.1-src.tar.gz";
    md5 = "b598ae6b7e765a92e13667b0a80392f4";
  };
  buildInputs = [ ant java.jdk];
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];
  buildPhase = ''
    ant jar
  '';
  installPhase = ''
    ls -l && false
    mkdir -p $out/share/java/
    mv *.jar $_ 
  '';
}
