{ utils, wiretap, wiretap-tools, lib}:
let wiretap_ = wiretap;
in rec {
  wiretap =
    timelimit:
    options @ {
      postprocess ? ""
      , settings ? []
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
        let tmp_timelimit=$timelimit
        export timelimit=${toString timelimit}
        analyse "wiretap-run" java -javaagent:$wiretap/share/java/wiretap.jar \
          $settings -cp $classpath $mainclass $args < $stdin
        export timelimit=$tmp_timelimit
      '';
      inherit postprocess;
    } // removeAttrs options ["settings"]) benchmark;

  wiretapSurveil =
    options:
    logging @ {
      depth ? 100000
    , ignoredprefixes ? "edu/ucla/pls/wiretap,java,sun"
    , timelimit ? 120
    }:
    wiretap timelimit (options // {
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
    , provers ? ["dirk"]
    , filter ? "unique,lockset"
    , chunkSize ? 10000
    , chunkOffset ? 5000
    , timelimit ? 3600  # 1 hours.
    , solve-time ? 120000 # in milis
    , solver ? "z3:qf_lra"
    , verbose ? false
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
        wiretap-tools size $sandbox/_wiretap/wiretap.hist > history.size.txt
        wiretap-tools count $sandbox/_wiretap/wiretap.hist > history.count.txt
        for prover in $provers; do
          analyse "wiretap-tools-$prover" wiretap-tools \
              ${cmd} ${if verbose then "-v" else ""} -h -p $prover \
              ${if (cmd == "deadlocks" || cmd == "dataraces" || cmd == "bugs") 
                then "--chunk-size ${toString chunkSize} --chunk-offset ${toString chunkOffset} --solve-time ${toString solve-time} --solver ${solver}"
              else ""
            } -f ${filter} $sandbox/_wiretap/wiretap.hist > "$prover.${cmd}.txt"
            cat "$prover.${cmd}.txt"
        done | sort -u > lower
        if [ "$ignoreSandbox" == "0" ]; then
           rm -r $sandbox
        fi
      '';
    };
}
