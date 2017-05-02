{ utils, reachable-methods }:
let detector = ./reflection.sh; in rec
{
  reflection = benchmark: utils.mkAnalysis {
      name = "reflection";
      tools = [ benchmark.java.jdk ];
      analysis = ''
        analyse "reflection" bash ${detector}
      '';
  } benchmark;

  comp = utils.cappedOverview "reflection-comp" reachable-methods.world [
    reflection
    reachable-methods.petabloxDynamic
  ];
}
