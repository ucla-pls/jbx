{ stdenv, fetchurl }:
{
  daikon = stdenv.mkDerivation {
    name = "daikon";
    src = fetchurl { 
      url = "http://www.csl.sri.com/users/schaef/jars/daikon.jar";
      md5 = "6b564a3f0b3ff1abf70a44cd66bc210f";
    };
    phases = "installPhase";
    installPhase = ''
      mkdir -p $out/share/java
      cp $src $_/daikon.jar
    '';
  };
}
