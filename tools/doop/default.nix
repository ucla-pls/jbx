{stdenv, fetchurl, logicblox, makeWrapper, jre, coreutils, gnused, time}:
let
doop160133 = stdenv.mkDerivation {
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
      --prefix PATH : ${time}/bin \
      --prefix PATH : ${jre}/bin \
      --prefix PATH : ${coreutils}/bin \
      --prefix PATH : ${gnused}/bin \
      --set LOGICBLOX_HOME ${logicblox} \
      --set DOOP_HOME $out/doop \
      --set LD_LIBRARY_PATH ""
  '';
  #inherit jre;
  #inherit logicblox;
  #inherit gcc;
};
doop5459247Beta = stdenv.mkDerivation {
  name = "doop";
  version = "r5459247-beta";
  src = fetchurl {
    url = "http://doop.program-analysis.org/software/doop-r5459247-beta-bin.tar.gz";
    md5 = "0a3d12132fc3649611aa4197febeb227";
  };
  buildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/doop
    cp -r * $out/doop
    mkdir -p $out/bin
    makeWrapper $out/doop/run $out/bin/doop \
      --prefix PATH : ${jre}/bin \
      --prefix PATH : ${coreutils}/bin \
      --set LOGICBLOX_HOME ${logicblox} \
      --set DOOP_HOME $out/doop \
      --set LD_LIBRARY_PATH ""
  '';
  inherit jre;
  inherit logicblox;
};
in doop5459247Beta 



