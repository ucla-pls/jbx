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
  # run: is an anlysis which can be specialiced using a set of
  # inputs. 
  run =
    # The first argument, the inputs to the benchmark
    input @ {
      name ? "" # Name of the input set.
      , stdin ? "" # The stdin sent to the process.
      , args ? [] # A list of arguments. 
      , ... # Maybe more things...
      }:
    # The second argument, the benchmark.
    benchmark @ {
      name # The name of the benchmark
      , build # The derivation, with the jar file
      , jarfile # The name of the jar file located in ../share/java/
      , mainclass # The main class
      , jreversion # the java version used to compile it.
      , ... # Maybe more things
    }:
    stdenv.mkDerivation {
      inherit (pkgs) time;
      inherit (benchmark) build jarfile mainclass;
      inputargs = args;
      stdin = stdin;
      jre = getAttr ("jre" + jreversion) pkgs;
      name = "${benchmark.name}-${input.name}";
      builder = ./run.sh;
    };

  # runAll is a little tool that runs all the inputs denoted
  # in the `runs` attribute field. The runAll function therfor only
  # needs the benchmark suite.
  runAll =
    benchmark @ {
        name
      , inputs # The function only cares about the runs list
      , ...
    }:
    let
      runs = map (i: run i benchmark) benchmark.inputs;
    in stdenv.mkDerivation {
       inherit runs;
       name = "${benchmark.name}-all";
       builder = ./runall.sh;
    };
    
}
