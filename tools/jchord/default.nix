{ stdenv, fetchgit, fetchurl, makeWrapper, jdk7, jre7, ant}:
let from_git = options @ {
    version,
    url? "https://bitbucket.org/pag-lab/jchord.git",
    branchName ? "master",
    rev ? "07e10a2849706ef7687f852f2e1ea26baba4bb8b",
    md5 ? "7462d8b23be9d6e69c9d0f0673a09b96"
  }:
  stdenv.mkDerivation {
    name = "jchord";
    inherit version;
    src = fetchgit { inherit url branchName rev md5; };
    buildInputs = [ant jdk7 makeWrapper];
    buildPhase = ''
      cd main
      ant compile
    '';
    installPhase = ''
      mkdir -p $out/share/java $out/bin
      mv chord.jar $out/share/java/
      makeWrapper ${jre7}/bin/java $out/bin/jchord \
         --add-flags "-cp $out/share/java/chord.jar chord.project.Boot" \
         --prefix PATH ":" ${jre7}/bin #Java is called from chord
    '';
  };
  from_tar = options @ { 
    version,
    file ? "chord-src-${version}.tar.gz",
    url ? "https://bitbucket.org/pag-lab/jchord/downloads/${file}",
    md5 ? "7462d8b23be9d6e69c9d0f0673a09b96",
  }:
    stdenv.mkDerivation {
      name = "jchord";
      inherit version;
      src = fetchurl { inherit url md5; };
      buildInputs = [ant jdk7 makeWrapper];
      buildPhase = ''
        ant compile
      '';
      installPhase = ''
        mkdir -p $out/share/java $out/bin
        mv chord.jar $out/share/java/
        makeWrapper ${jre7}/bin/java $out/bin/jchord \
           --add-flags "-cp $out/share/java/chord.jar chord.project.Boot" \
           --prefix PATH ":" ${jre7}/bin #Java is called from chord
      '';
    };
in {
  jchord-head = from_git { 
    version = "2.1.07e10";
    rev = "07e10a2849706ef7687f852f2e1ea26baba4bb8b";
    md5 = "7462d8b23be9d6e69c9d0f0673a09b96";
  };
  jchord-2_0 = from_tar {
    version = "2.0";
    md5 = "3fbbaf40a0d689b79672c765ef9e1c9f";
  };
}
