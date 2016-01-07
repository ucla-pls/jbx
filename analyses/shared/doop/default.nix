{pkgs, tools, mkAnalysis}:
rec {
  # This is the base analysis, all the others merly are instanciations
  # of this.
  base =
    options @ { # options related to the execution
      mode # the name of the analysis, e.g. 'context-insensitive'
    }:
    env: # the environment
    benchmark: # the benchmark
    mkAnalysis (options // {
      inherit (benchmark) build jarfile mainclass;
      env = env;
      mode = mode;
      name = "doop-${mode}-${benchmark.name}";
      analysis = ./doop.sh;
      doop = tools.doop;
    });

  context-insensitive = options: base (options // {mode = "context-insensitive";});
}

