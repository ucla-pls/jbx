{mkAnalysis, compose}:
rec {
  # run: is an anlysis which can be specialiced using a set of
  # inputs. The run also takes an environment variable. 
  run =
    # The first argument, the environment in witch its run. 
    env: # So far there is no requirements to the environment.
    # The second argument, the inputs to the benchmark
    input @ {
      name ? "" # Name of the input set.
      , stdin ? "" # The stdin sent to the process.
      , args ? [] # A list of arguments. 
      , setup ? "" # A setup hook
      , ... # Maybe more things...
      }:
    # The third argument, the benchmark.
    benchmark @ {
      name # The name of the benchmark
      , build # The derivation, with the jar file
      , jarfile # The name of the jar file located in ../share/java/
      , mainclass # The main class
      , java # the java version used to compile it.
      , data # evn. some data which we can run stuff on
      , libraries
      , ... # Maybe more things
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
    };

  # runAll is a little tool that runs all the inputs denoted
  # in the `runs` attribute field. The runAll function therfor only
  # needs the benchmark suite.
  runAll =
    env: # Passed directly to the run function.
    benchmark @ {
        name
      , inputs # The function only cares about the runs list
      , ...
    }:
    let
      analyses = map (i: run env i benchmark) benchmark.inputs;
    in compose analyses { name = "${benchmark.name}-all"; };
}
