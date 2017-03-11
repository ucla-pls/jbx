{ utils, wiretap, wiretap-tools, lib}:
let wiretap_ = wiretap;
in rec {
  wiretap =
    options @ {
      postprocess ? ""
      , settings ? []
      , timelimit ? 1800
      , ...
    }:
    benchmark:
    let
      inherit (lib.strings) concatStringsSep concatMapStringsSep;
      ppsettings = concatMapStringsSep " " (o: "-Dwiretap.${o.name}=${o.value}");
    in utils.mkDynamicAnalysis ({
      name = "wiretap";
      wiretap = wiretap_ benchmark.java;
      settings = ppsettings ( [
        ] ++ settings );
      analysis = ''
        analyse "wiretap-run" java -javaagent:$wiretap/share/java/wiretap.jar \
          $settings -cp $classpath $mainclass $args < $stdin
      '';
      inherit postprocess timelimit;
    } // removeAttrs options ["settings"]) benchmark;

  wiretapSurveil =
    options:
    logging @ {
      depth ? 100000
    , ignoredprefixes ? "edu/ucla/pls/wiretap,java,sun"
    , ...
    }:
    wiretap (options // {
      settings = [
        { name = "recorder";         value = "BinaryHistoryLogger"; }
        { name = "ignoredprefixes";  value = ignoredprefixes; }
        { name = "loggingdepth";     value = "${toString depth}"; }
        { name = "classfilesfolder"; value = "./_wiretap/classes"; }
      ];
    });

  surveil =
    options @ {
      logging ? {}
      , ...
    }:
    utils.afterD (wiretapSurveil {} logging) (surveilBase options);

  surveilFlat =
    options @ {
      logging ? {}
      , ...
    }:
    wiretapSurveil (surveilBase options) options.logging;

  surveilBase =
    options @
    { name ? "surveil"
    , cmd ? "parse"
    , provers ? ["kalhauge"]
    , filter ? "unique,lockset"
    , chunkSize ? 10000
    , chunkOffset ? 5000
    , timelimit ? 3600  # 1 hours.
    , verbose ? true
    , logging ? {}
    , ignoreSandbox ? true
    }:
    {
      inherit name timelimit provers ignoreSandbox;
      tools = [ wiretap-tools ];
      postprocess = ''
        runtime_deadlocks="$sandbox/_wiretap/deadlocks.txt"
        if [ -e $runtime_deadlocks ]; then
           for i in $(awk '{print $2}' "$runtime_deadlocks"); do
             sed "$((i + 1))q;d" "$sandbox/_wiretap/instructions.txt"
           done | sort | sed 'N;s/\n/ /' > "runtime-deadlock.txt"
        fi
        for prover in $provers; do
          analyse "wiretap-tools-$prover" wiretap-tools \
              ${cmd} ${if verbose then "-v" else ""} -p $prover \
              ${if (cmd == "deadlocks" || cmd == "dataraces") && chunkSize > 0
                          then "--chunk-size ${toString chunkSize} --chunk-offset ${toString chunkOffset}"
              else ""
            } -f ${filter} $sandbox/_wiretap/wiretap.hist > "$prover.${cmd}.txt"
            cat "$prover.${cmd}.txt"
        done | sort -u > lower

      '';
    };
}
