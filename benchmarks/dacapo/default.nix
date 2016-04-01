{ callPackage, stdenv, unzip, utils} :
let 
  inherit (utils) callBenchmark;
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
  withSrc = { inherit daCapoSrc; };
in rec {
  avrora = callBenchmark ./avrora {};
  batik = callBenchmark ./batik withSrc;
  h2 = callBenchmark ./h2 withSrc;
  sunflow = callBenchmark ./sunflow {};
  pmd = callBenchmark ./pmd withSrc;
  luindex = callBenchmark ./luindex withSrc;
  lusearch = callBenchmark ./lusearch withSrc;
  fop = callBenchmark ./fop withSrc;
  xalan = callBenchmark ./xalan withSrc;
  jython = callBenchmark ./jython withSrc;
  
  dacapo-harness = callPackage ./all {};
  
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
        ] ++ dacapo-harness;
}
