{ lib, utils }:
options @ {
  subanalyses
  , jchord 
  , reflection ? "dynamic" # "static", "static_cast" or "none"
  , name ? lib.concatStringsSep "_" subanalyses
  , tools ? []
  , timelimit ? 3600
  , ...
}:
benchmark: 
let 
  inherit (lib.strings) concatStringsSep concatMapStringsSep;
  inherit (benchmark) inputs;
  subanalysis = lib.concatStringsSep "," subanalyses;
  options_ = options // {
    name = "jchord-${name}";
    analysis = ''
      eval "echo \"$settings\"" > chord.properties
      analyse "jchord" java -Dchord.work.dir=`pwd` chord.project.Boot 
    '';
    inherit timelimit;
    tools = [ jchord benchmark.java.jre ] ++ tools;
    settings = ppsettings ( [
      { name = "main.class";     value = benchmark.mainclass;                        }
      { name = "run.analyses";   value = concatStringsSep "," subanalyses;           }
      { name = "err.file";       value = "/dev/stderr";                              }
      { name = "out.file";       value = "/dev/stdout";                              }
      { name = "jvmargs";        value = "-ea -Xmx40960m";                           }
      { name = "class.path";     value = "$classpath";                               }
      { name = "reflect.kind";   value = reflection;                                 }
      { name = "run.ids";        value = concatMapStringsSep "," (x: x.name) inputs; }
      ] ++ builtins.map (input: {
        name = "args.${input.name}"; 
        value = concatStringsSep " " input.args; 
      }) inputs 
    );
  };
  ppsettings = concatMapStringsSep "\n" (o: "chord.${o.name}=${o.value}");
in utils.mkAnalysis options_ benchmark
