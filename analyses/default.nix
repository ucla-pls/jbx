# analysis:
# author: Christian Gram Kalhauge
# description: |
#  This module contains the analyses, which can be used on
#  benchmarks. All attributes is either a attribute set of anlyses, a
#  function that takes a benchmark and returns a derivation (an
#  analysis), or a function that can be used to create an analysis.

{callPackage, utils}:
rec {
  run = callPackage ./run {} ;
  # call-graph = import ./call-graph { 
  #   inherit shared tools;
  # };
  # postprocessors = pkgs.callPackage ./postprocessors { 
  #   inherit batch compose;
  # };
  # reachable-methods = pkgs.callPackage ./reachable-methods { 
  #   inherit shared tools mkAnalysis compose postprocessors;
  # };
  # deadlock = pkgs.callPackage ./deadlock { 
  #   inherit shared tools postprocessors;
  # };

  # inherit shared;
}
