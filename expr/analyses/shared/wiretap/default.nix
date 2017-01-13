{ utils, wiretap, wiretap-tools, lib}:
let wiretap_ = wiretap;
in rec {
  wiretap =
    options @ {
      postprocess ? "",
      settings ? []
    }:
    benchmark:
    let
      inherit (lib.strings) concatStringsSep concatMapStringsSep;
      ppsettings = concatMapStringsSep " " (o: "-Dwiretap.${o.name}=${o.value}");
    in
    utils.mkDynamicAnalysis {
      name = "wiretap";
      timelimit = 1800;
      wiretap = wiretap_ benchmark.java;
      settings = ppsettings ( [
        ] ++ settings );
      analysis = ''
        echo $classpath
        analyse "wiretap-run" java -javaagent:$wiretap/share/java/wiretap.jar \
          $settings\
          -cp $classpath $mainclass $args < $stdin
      '';
      inherit postprocess;
    } benchmark;

  surveil =
    options @
     { name ? "surveil"
    , depth ? 100000
    , cmd ? "parse"
    , chunkSize ? 10000
    , chunkOffset ? 5000
    }:
    utils.afterD (
      wiretap {
        settings = [
          { name = "recorder";        value = "BinaryHistoryLogger"; }
          { name = "ignoredprefixes"; value = "edu/ucla/pls/wiretap,java,sun"; }
          { name = "loggingdepth";    value = "${toString depth}"; }
        ];
      }
    ) {
      inherit name;
      tools = [ wiretap-tools ];
      postprocess = ''
        wiretap-tools ${cmd} -v ${if (cmd == "deadlocks" || cmd == "dataraces") && chunkSize > 0
            then "--chunk-size ${toString chunkSize} --chunk-offset ${toString chunkOffset}"
            else ""
           } $sandbox/_wiretap/wiretap.hist > $out/lower
      '';
    };
}
