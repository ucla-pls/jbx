# analysis:
# author: Christian Gram Kalhauge
# description: |
#  This module contains the analyses, which can be used on
#  benchmarks. All attributes is either a attribute set of anlyses, a
#  function that takes a benchmark and returns a derivation (an
#  analysis), or a function that can be used to create an analysis.

{pkgs, tools}:
let
  inherit (pkgs) stdenv time jre;
  inherit (pkgs.lib.strings) concatStringsSep;
  inherit (builtins) getAttr map;
in rec {

  # mkAnalysis; creates analyese wich is timed and
  mkAnalysis =
    options @ {
        env  # the environment in wich the analysis is run, this is
	     # needed for reliable timing results.
      , name  # The name of the analysis. 
      , analysis  # The file or string needed to be executed
      , ... # Other environment variables
    }:
    stdenv.mkDerivation (options // {
      inherit (pkgs) time;
      env = (e: "${e.name}: " +
                "${toString e.cores}x ${e.processor}, " +
		"${toString e.memorysize}mb ${e.memory}"
            ) env;
      builder = ./analysis.sh;
    });
    
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
      , ... # Maybe more things...
      }:
    # The third argument, the benchmark.
    benchmark @ {
      name # The name of the benchmark
      , build # The derivation, with the jar file
      , jarfile # The name of the jar file located in ../share/java/
      , mainclass # The main class
      , jreversion # the java version used to compile it.
      , ... # Maybe more things
    }: mkAnalysis {
      name = "${benchmark.name}-${input.name}";
      inherit (benchmark) build jarfile mainclass;
      env = env;
      inputargs = args;
      stdin = stdin;
      jre = getAttr ("jre" + jreversion) pkgs;
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
      runs = map (i: run env i benchmark) benchmark.inputs;
    in stdenv.mkDerivation {
       inherit runs;
       name = "${benchmark.name}-all";
       builder = ./runall.sh;
    };

   doop =  import ./doop {inherit pkgs tools; };
}
