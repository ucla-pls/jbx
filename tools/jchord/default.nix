{ stdenv, fetchgit, makeWrapper, jdk7, jre7, ant}:
stdenv.mkDerivation {
  name = "jchord";
  version = "2.1.ec123fc";
  src = fetchgit {
    url = "https://kalhauge@bitbucket.org/pag-lab/jchord.git";
    branchName = "master";
    rev = "ec123fc7b19e5dbb66cfce6495edad8a7a251459";
    md5 = "aeda5feaa679648fe9af86086f19bf33";
  };
  patches = [ ./petablox.patch ];
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
}
