{ lib, utils, mkLogicBloxAnalysis, java }:
options @ {
  subanalyses
  , petablox
  , logicblox ? null
  , reflection ? "external" # "none" or "dynamic"
  , name ? lib.concatStringsSep "_" subanalyses
  , tools ? []
  , timelimit ? 3600
  , ...
}:
benchmark: 
let 
  inherit (lib.strings) concatStringsSep concatMapStringsSep;
  inherit (benchmark) inputs;
  lbname = if logicblox != null then "lb-" + logicblox.version else "bddbddb";
  extend = "${lbname}-${name}"; 
  lbuse = logicblox != null 
    && builtins.all (a: a != "logicblox-export") subanalyses;
  engine = if lbuse then "logicblox" else "bddbddb";
  options_ = options // {
    name = "petablox-${extend}";
    analysis = ''
      eval "echo \"$settings\"" > petablox.properties
      analyse "petablox" java -Dpetablox.work.dir=`pwd` petablox.project.Boot 
    '';
    tools = [ petablox java.java7.jre ] ++ tools;
    settings = ppsettings ( [
      { name = "datalog.engine"; value = engine;                                     }
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
  ppsettings = concatMapStringsSep "\n" (o: "petablox.${o.name}=${o.value}");
in 
(if logicblox != null then mkLogicBloxAnalysis else utils.mkAnalysis) options_ benchmark
