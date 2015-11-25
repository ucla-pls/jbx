{ stdenv, fetchurl }: java:
stdenv.mkDerivation {
  name = "common-cli";
  src = fetchurl {
    url = "http://archive.apache.org/dist/commons/cli/binaries/commons-cli-1.2-bin.tar.gz";
    md5 = "a05956c9ac8bacdc2b8d07fb2cb331ce";
  };
  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    mkdir -p $out/share/java 
    mv commons-cli-1.2.jar $_ 
  '';
}
