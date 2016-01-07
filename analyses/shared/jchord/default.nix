{ lib, jchord, mkLogicBloxAnalysis, mkAnalysis}:
options @ {
  subanalyses
  , name ? lib.concatStringsSep "_" subanalyses
  , datalog ? true
  , postprocessing ? ""
}:
env:
benchmark: 
let 
  subanalysis = lib.concatStringsSep "," subanalyses;
  options = {
    name = "jchord-${if datalog then "dlog" else "bddbddb"}-${name}-${benchmark.name}";
    analysis = ./jchord.sh;
    inherit env;
    
    jchord = jchord;
    jre = benchmark.java.jre;
    inherit (benchmark) mainclass build libraries;

    settings = ''
chord.main.class=${benchmark.mainclass}
chord.run.analyses=${subanalysis}
${if datalog then "chord.datalog.engine=logicblox4" else ""}
chord.err.file=/dev/stderr
chord.out.file=/dev/stdout
'';
    inherit postprocessing; 
  };
in 
if datalog 
  then mkLogicBloxAnalysis options 
  else mkAnalysis options
