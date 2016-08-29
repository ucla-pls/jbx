{ stdenv, fetchprop, unzip, ant}:
{
  wiretap = java: stdenv.mkDerivation {
    name = "wiretap";
    src = fetchprop {
      url = "wiretap.zip";
      md5 = "54ca0342658605d5773e0f823b2f2d20";
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
