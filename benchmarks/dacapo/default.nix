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
  h2 = callBenchmark ./h2 { inherit daCapoSrc; };
  sunflow = callBenchmark ./sunflow {};
  pmd = callBenchmark ./pmd { inherit daCapoSrc; };
  luindex = callBenchmark ./luindex { inherit daCapoSrc; };
  lusearch = callBenchmark ./lusearch { inherit daCapoSrc; };
  fop = callBenchmark ./fop { inherit daCapoSrc; };
  xalan = callBenchmark ./xalan { inherit daCapoSrc; };
  jython = callBenchmark ./jython { inherit daCapoSrc; };

  # Does not work .. no eclipse found
  # eclipse = pkgs.callPackage ./eclipse { };
  
  all = [ avrora
          batik
          fop
          # h2
          jython
          luindex
          lusearch
          pmd
          sunflow
          xalan
        ];
}
