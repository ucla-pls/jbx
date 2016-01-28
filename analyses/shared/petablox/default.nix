{ lib, mkLogicBloxAnalysis, mkAnalysis}:
options @ {
  subanalyses
  , petablox
  , logicblox ? null
  , reflection ? "dynamic" # "none" or "external"
  , name ? lib.concatStringsSep "_" subanalyses
  , postprocessing ? ""
}:
env:
benchmark: 
let 
  inputs = benchmark.inputs;
  subanalysis = lib.concatStringsSep "," subanalyses;
  lbname = if logicblox != null then "lb-" + logicblox.version else "bddbddb";
  extend = "${lbname}-${name}-${benchmark.name}"; 
  options = {
    name = "petablox-${extend}";
    analysis = ./petablox.sh;
    inherit env;
    tools = [ petablox benchmark.java.jre ];
    inherit (benchmark) mainclass build libraries data;
    settings = ''
petablox.main.class=${benchmark.mainclass}
petablox.run.analyses=${subanalysis}
${if logicblox != null then "petablox.datalog.engine=logicblox4" else ""}
petablox.err.file=/dev/stderr
petablox.out.file=/dev/stdout

petablox.reflect.kind=${reflection}
petablox.run.ids=${lib.strings.concatMapStringsSep "," (x: x.name) inputs}
${
  lib.strings.concatMapStringsSep "\n" (input: 
    "petablox.args.${input.name}=${lib.strings.concatStringsSep " " input.args}"
  ) inputs 
}
'';
    inherit postprocessing; 
  };
in 
if logicblox != null 
  then mkLogicBloxAnalysis benchmark.java logicblox options
  else mkAnalysis options
