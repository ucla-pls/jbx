{ stdenv, fetchprop, unzip, ant}:
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchprop {
      url = "wiretap.zip";
      md5 = "3f6f097e8e827521231d13b7a99ceba5";
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
