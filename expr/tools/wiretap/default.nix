{ stdenv, fetchprop, unzip, ant}:
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchprop {
      url = "wiretap.zip";
      md5 = "84e8a949cb626d510b5ea9b863517075";
    };
    buildInputs = [ unzip ant java.jdk ];
    phases = "buildPhase installPhase";
    buildPhase = ''
      unzip $src
      ant
    '';
    installPhase = ''
      mkdir -p $out/share/java
      cp build/wiretap.jar $out/share/java
    '';
  };
}
