{ pkgs, callBenchmark} :
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

  avrora = callBenchmark ./avrora {};
  batik = callBenchmark ./batik { inherit daCapoSrc; };
  # h2 = pkgs.callBenchmark ./h2 { };
  sunflow = callBenchmark ./sunflow {};

  # Does not work .. no eclipse found
  # eclipse = pkgs.callPackage ./eclipse { };

  # fop = pkgs.callPackage ./fop {};

}
