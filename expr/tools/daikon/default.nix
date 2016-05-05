{ stdenv, fetchurl }:
{
  daikon = stdenv.mkDerivation {
    name = "daikon";
    src = fetchurl { 
      url = "https://plse.cs.washington.edu/daikon/download/daikon-5.3.2.tar.gz";
      md5 = "a2b8b1d65b1b311111448b9753a50dfd";
    };
    phases = "unpackPhase installPhase";
    installPhase = ''
      mkdir -p $out/share/java
      cp daikon.jar $_
    '';
  };
}
