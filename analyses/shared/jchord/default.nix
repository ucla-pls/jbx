{ lib, jchord, mkAnalysis}:
options @ {
  subanalyses
  , name ? lib.concatStringsSep "_" subanalyses
  , postprocessing ? ""
}:
env:
benchmark: 
let 
  subanalysis = lib.concatStringsSep "," subanalyses;
  options = {
    name = "jchord-${name}-${benchmark.name}";
    analysis = ./jchord.sh;
    inherit env;
    
    jchord = jchord;
    jre = benchmark.java.jre;
    inherit (benchmark) mainclass build libraries;

    settings = ''
chord.main.class=${benchmark.mainclass}
chord.run.analyses=${subanalysis}
chord.err.file=/dev/stderr
chord.out.file=/dev/stdout
'';
    inherit postprocessing; 
  };
in mkAnalysis options
