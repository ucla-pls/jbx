{ mkAnalysis, compose }:
rec {
  # run: is an anlysis which can be specialiced using a set of
  # inputs. The run also takes an environment variable. 
  run =
    # The first argument, the environment in which it's run. 
    env: # So far there is no requirements to the environment.
    # The second argument, the benchmark.
    benchmark @ {
      name # The name of the benchmark
      , build # The derivation, with the jar file
      , mainclass # The main class
      , java # the java version used to compile it.
      , data # evn. some data which we can run stuff on
      , libraries
      , ... # Maybe more things
    }:
    # The third argument, the input to the benchmark
    input @ {
      name ? "" # Name of the input set.
      , stdin ? "" # The stdin sent to the process.
      , args ? [] # A list of arguments. 
      , setup ? "" # A setup hook
      , ... # Maybe more things...
    }:
    mkAnalysis {
      name = "${benchmark.name}-${input.name}";
      inherit (benchmark) mainclass data libraries build;
      env = env;
      inputargs = args;
      setup = setup;
      stdin = stdin;
      jre = java.jre;
      analysis = ./run.sh;
      timelimit = 300; # 5 minutes
    };

  # runAll is an analysis that runs all the inputs denoted in the 
  # `inputs` attribute field. The runAll function therfor only
  # needs the benchmark suite and the environment.
  runAll =
    env: # Passed directly to the run function.
    benchmark @ {
      name
      , inputs # The function only cares about the inputs list
      , ...
    }:
    let analyses = map (run env benchmark) benchmark.inputs;
    in compose analyses { 
      name = "${benchmark.name}-all"; 
      combine = ''
        awk 'BEGIN { FS=","; OFS=","; S = 0 ; R = 0; C = 0} 
          { if (NR > 1) {
            S = $2 + S; 
            if ($6 == 0) 
              R = R + 1; 
            C += 1;
            }
          }
          END {
            printf "${benchmark.name}-runall,%s,%s/%s\n", S, R, C
          }' <$out/base.csv >$out/result.csv
      '';
    };
}


