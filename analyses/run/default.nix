{ utils }:
let inherit (utils) mkDynamicAnalysis onAllInputs;
in rec {
  # run: is an anlysis which can be specialiced using a set of
  # inputs. The run also takes an environment variable. 
  run = 
    benchmark: 
    mkDynamicAnalysis {
      name = "run";
      analysis = ./run.sh;
      timelimit = 300; # 5 minutes
      tools = [benchmark.java.jre];
      inherit (benchmark) mainclass;
    } benchmark;

  # runAll is an analysis that runs all the inputs denoted in the 
  # `inputs` attribute field. The runAll function therfor only
  # needs the benchmark suite and the environment.
  runAll = onAllInputs run {};
}


