{ lib, utils, mkLogicBloxAnalysis, java }:
options @ {
  subanalyses
  , petablox
  , logicblox ? null
  , reflection ? "external" # "none" or "dynamic"
  , name ? lib.concatStringsSep "_" subanalyses
  , tools ? []
  , timelimit ? 3600
  , settings ? []
  , reflection-timelimit ? 300
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
  engine = if lbuse then "logicblox4" else "bddbddb";
  options_ = options // {
    name = "petablox-${extend}";
    analysis = ''
      eval "echo \"$settings\"" > petablox.properties
      analyse "petablox" java -Dpetablox.work.dir=`pwd` petablox.project.Boot 
    '';
    tools = [ petablox benchmark.java.jre ] ++ tools;
    inherit timelimit;
    settings = ppsettings ( [
      { name = "datalog.engine";       value = engine;                                     }
      { name = "main.class";           value = benchmark.mainclass;                        }
      { name = "run.analyses";         value = concatStringsSep "," subanalyses;           }
      { name = "err.file";             value = "/dev/stderr";                              }
      { name = "out.file";             value = "/dev/stdout";                              }
      { name = "jvmargs";              value = "-Xmx4096m";                               }
      { name = "runtime.jvmargs";      value = "-Xmx4096m";                               }
      { name = "class.path";           value = "$classpath";                               }
      { name = "reflect.kind";         value = reflection;                                 }
      { name = "src.path";             value = "${benchmark.build}/src";                   }
      { name = "run.ids";              value = concatMapStringsSep "," (x: x.name) inputs; }
      { name = "reflection.timeout";   value = "${toString reflection-timelimit}000";      }
      { name = "dynamic.timeout";      value = "${toString reflection-timelimit}000";      }
      { name = "reflection.haltonerr"; value = "false";                                    }
      ] ++ builtins.map (input: {
        name = "args.${input.name}"; 
        value = concatStringsSep " " input.args; 
      }) inputs ++ settings
    );
  };
  ppsettings = concatMapStringsSep "\n" (o: "petablox.${o.name}=${o.value}");
in 
(if logicblox != null then mkLogicBloxAnalysis else utils.mkAnalysis) options_ benchmark
