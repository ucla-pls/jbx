{ stdenv, fetchurl, unzip, ant }:
rec {
  soot-3_1_0 = stdenv.mkDerivation {
    name = "Soot";
    src = fetchurl { 
      url = "https://soot-build.cs.uni-paderborn.de/nexus/repository/soot-release/ca/mcgill/sable/soot/3.1.0/soot-3.1.0-jar-with-dependencies.jar";
      sha256 = "0q86sin27ddgk8snv1zxac2fi4vvqm9i8x9wv1dvjs8p4dncz368";
    };
    phases = "installPhase";
    installPhase = ''
    mkdir -p $out/share/java/
    cp $src $out/share/java/soot.jar
    '';
  };
  soot = soot-3_1_0;
}
