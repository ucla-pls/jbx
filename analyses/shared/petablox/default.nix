{ lib, mkLogicBloxAnalysis, mkAnalysis}:
options @ {
  subanalyses
  , petablox
  , logicblox ? null
  , reflection ? "dynamic" # "none" or "external"
  , name ? lib.concatStringsSep "_" subanalyses
  , postprocessing ? ""
  , tools ? []
  , timelimit ? 3600
}:
env:
benchmark: 
let 
  inputs = benchmark.inputs;
  lbname = if logicblox != null then "lb-" + logicblox.version else "bddbddb";
  extend = "${lbname}-${name}-${benchmark.name}"; 
  options = {
    name = "petablox-${extend}";
    analysis = ./petablox.sh;
    inherit env timelimit;
    tools = [ petablox benchmark.java.jre ] ++ tools;
    inherit (benchmark) mainclass build libraries data;
    settings = ''
petablox.main.class=${benchmark.mainclass}
petablox.run.analyses=${lib.concatStringsSep "," subanalyses}
${if (logicblox != null && builtins.all (a: a != "logicblox-export") subanalyses)
  then "petablox.datalog.engine=logicblox4" 
  else "petablox.datalox.engine=bddbddb"}
petablox.err.file=/dev/stderr
petablox.out.file=/dev/stdout
petablox.jvmargs="-ea -Xmx40960m"
petablox.runtime.jvmargs="-ea -Xmx40960m"

petablox.reflect.kind=${reflection}
petablox.run.ids=${lib.strings.concatMapStringsSep "," (x: x.name) inputs}
${
  lib.strings.concatMapStringsSep "\n" (input: 
    ''petablox.args.${input.name}=${lib.strings.concatStringsSep " " input.args}''
  ) inputs 
}
'';
    inherit postprocessing; 
  };
in 
if logicblox != null 
  then mkLogicBloxAnalysis benchmark.java logicblox options
  else mkAnalysis options
