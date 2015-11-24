{ pkgs } :
let
  inherit (pkgs) stdenv unzip;
in rec {
  daCapoSrc = stdenv.mkDerivation {
    name = "DaCapo";
    version = "9.12";
    src = ./dacapo-9.12-bach-src.zip;
    buildInputs = [ unzip ];
    unpackPhase='' 
      unzip $src
      sourceRoot=.
    '';
    installPhase=''
      mkdir $out
      cp -r * $out
    '';
    dontFixup=true;
  };

  avrora = pkgs.callBenchmark ./avrora {};

  # Warning not equivlient to dacapo, uses newer version.
  batik = pkgs.callBenchmark ./batik {};

  # Does not work .. no eclipse found
  # eclipse = pkgs.callPackage ./eclipse { };

  # fop = pkgs.callPackage ./fop {};

}
