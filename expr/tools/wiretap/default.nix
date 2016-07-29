{ stdenv, fetchprop }:
{
  wiretap = stdenv.mkDerivation {
    name = "wiretap";
    src = fetchprop {
      url = "svm.jar";
      md5 = "d1450cc88b9525c71aeed9a60c691823";
    };
    phases = "installPhase";
    installPhase = ''
      mkdir -p $out/share/java
      cp $src $out/share/java/svm.jar
    '';
  };
}
