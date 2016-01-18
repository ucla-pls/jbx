{ lib, mkLogicBloxAnalysis, mkAnalysis}:
options @ {
  subanalyses
  , petablox
  , logicblox ? null
  , name ? lib.concatStringsSep "_" subanalyses
  , postprocessing ? ""
}:
env:
benchmark: 
let 
  subanalysis = lib.concatStringsSep "," subanalyses;
  lbname = if logicblox != null then "lb-" + logicblox.version else "bddbddb";
  extend = "${lbname}-${name}-${benchmark.name}"; 
  options = {
    name = "petablox-${extend}";
    analysis = ./petablox.sh;
    inherit env;
    tools = [ petablox benchmark.java.jre ];
    inherit (benchmark) mainclass build libraries;
    settings = ''
petablox.main.class=${benchmark.mainclass}
petablox.run.analyses=${subanalysis}
${if logicblox != null then "petablox.datalog.engine=logicblox4" else ""}
petablox.err.file=/dev/stderr
petablox.out.file=/dev/stdout
'';
    inherit postprocessing; 
  };
in 
if logicblox != null 
  then mkLogicBloxAnalysis benchmark.java logicblox options
  else mkAnalysis options
