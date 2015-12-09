# analysis:
# author: Christian Gram Kalhauge
# description: |
#  This module contains the analyses, which can be used on
#  benchmarks. All attributes is either a attribute set of anlyses, a
#  function that takes a benchmark and returns a derivation (an
#  analysis), or a function that can be used to create an analysis.

{pkgs, tools}:
let
  inherit (pkgs) stdenv time;
  inherit (pkgs.lib.strings) concatStringsSep;
  inherit (builtins) getAttr map;
  
  logicblox = import ./logicblox {inherit mkAnalysis pkgs tools; };
  inherit (logicblox) mkLogicBloxAnalysis;
  
  # mkAnalysis; creates analyses which are timed and store all the
  # information the right places. It also runs the analysis in a
  # subfolder named sandbox.
  mkAnalysis =
    options @ {
        env  # the environment in which the analysis is run, this is
	     # needed for reliable timing results.
      , name  # The name of the analysis. 
      , analysis  # The file or string needed to be executed
      , ... # Other environment variables
    }:
    stdenv.mkDerivation (options // {
      utils = utils;
      env = (e: "${e.name}: " +
                "${toString e.cores}x ${e.processor}, " +
		            "${toString e.memorysize}mb ${e.memory}"
            ) env;
      builder = ./analysis.sh;
    });
  utils = pkgs.callPackage ./utils {};
in rec {

  # Compose: Takes a list of analyses, run them and perform post
  # actions to combine everything:
  # Takes mulitble hooks:
  #   combine: which is complete control
  #
  #   before, foreach, after: before and after is hooked called before
  #   and after a for loop, where foreach is called foreach iteration
  #   with the run directory as the `$run` argument.
  compose =
    results:
    options @ {
        name
      , ...
    }:
    stdenv.mkDerivation (options // {
      utils = utils;
      results = results;
      builder = ./compose.sh;
    });

  # The batch tool enables you to batch multible benchmarks with one
  # analysis this is especially usefull for during comparations. This
  # tool automatically 
  batch =
    analysis:
    options:
    benchmarks:
    rec {
      all = compose (builtins.attrValues byName) options;
      byName = builtins.listToAttrs
        (map (benchmark: {
	       name = benchmark.name;
	       value = analysis benchmark;
	     })
	     benchmarks);
      };

  # jarOf: helper function that finds the absolute path to jar of a
  # benchmark
  jarOf = benchmark: "${benchmark.build}/share/java/${benchmark.jarfile}";
    
  inherit (import ./run {inherit mkAnalysis compose;}) run runAll composeRun;
  doop =  import ./doop {inherit pkgs tools mkAnalysis; };
  jchord =  import ./jchord {inherit pkgs tools mkLogicBloxAnalysis jarOf mkAnalysis; };
}
