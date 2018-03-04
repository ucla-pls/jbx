{ stdenv, fetchprop, unzip, ant}:
{
  rvpredict = java: stdenv.mkDerivation {
    name = "rvpredict";
    src = fetchprop {
      url = "rvpredict.tar.gz";
      sha256 = "1ycr0kkp8clzw37yv3dnx3qqr3dnf48avghhm3zzppm6z0qph0ka";
    };
    buildInputs = [ unzip ant java.jdk ];
    phases = "unpackPhase patchPhase buildPhase installPhase";
    patches = [];
    buildPhase = ''
      ant
    '';
    installPhase = ''
      mkdir -p $out/share/java
      cp lib/* $out/share/java
    '';
  };
}


