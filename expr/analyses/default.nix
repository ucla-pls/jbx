# analysis:
# author: Christian Gram Kalhauge
# description: |
#  This module contains the analyses, which can be used on
#  benchmarks. All attributes is either a attribute set of anlyses, a
#  function that takes a benchmark and returns a derivation (an
#  analysis), or a function that can be used to create an analysis.

{callPackage, utils}:
let
  shared = callPackage ./shared {};
in rec {
  run =
    callPackage ./run {};

  stats =
    callPackage ./stats {};

  reachable-methods =
    callPackage ./reachable-methods { inherit shared; };

  deadlocks =
    callPackage ./deadlocks { inherit shared; };

  dataraces =
    callPackage ./dataraces { inherit shared; };

  data-flow-graph =
    callPackage ./data-flow-graph { inherit shared; };

  traces =
    callPackage ./traces {};

  reflection =
    callPackage ./reflection { inherit reachable-methods; };
}
