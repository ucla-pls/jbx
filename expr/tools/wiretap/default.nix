{ stdenv, fetchprop, unzip, ant}:
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchprop {
      url = "wiretap.zip";
      md5 = "44ce603f705c8a2be5f795d39e156c8b";
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
