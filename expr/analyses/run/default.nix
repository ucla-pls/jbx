{ utils }:
let inherit (utils) mkDynamicAnalysis onAllInputs;
in rec {
  # run: is an anlysis which can be specialiced using a set of
  # inputs. The run also takes an environment variable. 
  run = mkDynamicAnalysis {
      name = "run";
      timelimit = 300; # 5 minutes
      analysis = ''
        echo "'$args'"
        analyse "run" java -cp $classpath $mainclass $args < $stdin
      '';
      postprocess = ''
        if [[ "$RETVAL" -eq 0 ]]; then
            printf "$mainclass $args\t$(md5sum $stdin)\n" > $out/must
        else
            echo "Program failed with $RETVAL" > $out/error
        fi
      '';
    };

  # runAll is an analysis that runs all the inputs denoted in the 
  # `inputs` attribute field. The runAll function therfor only
  # needs the benchmark suite and the environment.
  runAll = onAllInputs run {};
}
