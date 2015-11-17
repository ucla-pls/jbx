{pkgs, tools, mkAnalysis}:
rec {
  # This is the base analysis, all the others merly are instanciations
  # of this.
  base =
    options @ { # options related to the execution
      type # the name of the analysis, e.g. 'context-insensitive'
    }:
    env: # the environment
    benchmark: # the benchmark
    mkAnalysis (options // benchmark // {
      env = env;
      name = "doop-${name}-${benchmark.name}";
      analysis = ./doop.sh;
      doop = tools.doop;
    });

  context-insensitive = options: base (options // {type = "context-insensitive";});
}

