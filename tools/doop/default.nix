{stdenv, fetchurl, logicblox, makeWrapper, jre}:
stdenv.mkDerivation {
  name = "doop";
  version = "r160113";
  src = fetchurl {
    url = "http://doop.program-analysis.org/software/doop-r160113-bin.tar.gz";
    md5 = "90b14b77b818f149e77406d17a9751c3";
  };
  patches = [ ./relative.patch ];
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/doop
    cp -r * $out/doop
    mkdir -p $out/bin
    makeWrapper $out/doop/run $out/bin/doop \
      --prefix PATH : ${jre}/bin \
      --set LOGICBLOX_HOME ${logicblox} \
      --set DOOP_HOME $out/doop \
      --set LD_LIBRARY_PATH ""
  '';
  inherit jre;
  inherit logicblox;
}
