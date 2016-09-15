{ stdenv, fetchprop, unzip, ant}:
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchprop {
      url = "wiretap.zip";
      md5 = "81b90988df0da41cc6416fb0bb3095c4";
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
