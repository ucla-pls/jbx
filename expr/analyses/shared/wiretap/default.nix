{ utils, wiretap, wiretap-tools, lib}:
let wiretap_ = wiretap;
in rec {
  wiretap =
    options @ {
      postprocess ? "",
      settings ? [], 
      timelimit ? 1800,
    }:
    benchmark:
    let
      inherit (lib.strings) concatStringsSep concatMapStringsSep;
      ppsettings = concatMapStringsSep " " (o: "-Dwiretap.${o.name}=${o.value}");
    in
    utils.mkDynamicAnalysis {
      name = "wiretap";
      wiretap = wiretap_ benchmark.java;
      settings = ppsettings ( [
        ] ++ settings );
      analysis = ''
        echo $classpath
        analyse "wiretap-run" java -javaagent:$wiretap/share/java/wiretap.jar \
          $settings\
          -cp $classpath $mainclass $args < $stdin
      '';
      inherit postprocess timelimit;
    } benchmark;

  wiretapSurveil =
    { timelimit ? 1800
    , depth ? 100000
    }:
    wiretap {
      inherit timelimit;
      settings = [
        { name = "recorder";         value = "BinaryHistoryLogger"; }
        { name = "ignoredprefixes";  value = "edu/ucla/pls/wiretap,java,sun"; }
        { name = "loggingdepth";     value = "${toString depth}"; }
        { name = "classfilesfolder"; value = "./_wiretap/classes"; }
      ];
    };

  surveil =
    options @
    { name ? "surveil"
    , cmd ? "parse"
    , prover ? "kalhauge"
    , filter ? "unique,lockset"
    , chunkSize ? 10000
    , chunkOffset ? 5000
    , timelimit ? 3600  # 1 hours.
    , verbose ? true
    , logging ? {}
    }:
    utils.afterD (wiretapSurveil logging) {
      inherit name timelimit;
      tools = [ wiretap-tools ];
      ignoreSandbox = true;
      postprocess = ''
        analyse "wiretap-tools" wiretap-tools ${cmd} ${if verbose then "-v" else ""} -p ${prover} ${if (cmd == "deadlocks" || cmd == "dataraces") && chunkSize > 0
            then "--chunk-size ${toString chunkSize} --chunk-offset ${toString chunkOffset}"
            else ""
           } -f ${filter} $sandbox/_wiretap/wiretap.hist > $out/lower
      '';
    };
}
