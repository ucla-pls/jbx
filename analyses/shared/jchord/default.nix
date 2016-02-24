{ lib, mkAnalysis}:
options_ @ {
  subanalyses
  , jchord 
  , name ? lib.concatStringsSep "_" subanalyses
  , reflection ? "dynamic" # "static", "static_cast" or "none"
  , postprocessing ? ""
  , tools ? []
  , timelimit ? 3600
  , ...
}:
env:
benchmark: 
let 
  subanalysis = lib.concatStringsSep "," subanalyses;
  inputs = benchmark.inputs;
  options = options_ // {
    name = "jchord-${name}-${benchmark.name}";
    analysis = ./jchord.sh;
    inherit env timelimit;
    tools = [ jchord benchmark.java.jre ] ++ tools;
    inherit (benchmark) mainclass build libraries data;

    settings = ''
chord.main.class=${benchmark.mainclass}
chord.run.analyses=${subanalysis}
chord.err.file=/dev/stderr
chord.out.file=/dev/stdout

chord.jvmargs="-ea -Xmx40960m"
chord.runtime.jvmargs="-ea -Xmx40960m"

chord.reflect.kind=${reflection}
chord.run.ids=${lib.strings.concatMapStringsSep "," (x: x.name) inputs}
${
  lib.strings.concatMapStringsSep "\n" (input: 
    ''chord.args.${input.name}=${lib.strings.concatStringsSep " " input.args}''
  ) inputs 
}
'';
    inherit postprocessing; 
  };
in mkAnalysis options
