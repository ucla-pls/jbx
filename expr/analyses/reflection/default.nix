{ utils, reachable-methods, python3 }:
let
  caller-methods = ./reflection-callers.sh;
  compare = ./reflection-comp.py;
in rec {
  reflection-caller-methods = benchmark: utils.mkAnalysis {
      name = "reflection-caller-methods";
      tools = [ benchmark.java.jdk ];
      analysis = ''
        analyse "reflection-caller-methods" bash ${caller-methods}
      '';
  } benchmark;

  comp = benchmark: env: utils.mkAnalysis {
    name = "reflection-comp";
    reflection_callers = (reflection-caller-methods benchmark env).out;
    reachable_methods = (reachable-methods.overview benchmark env).out;
    tools = [ python3 ];
    analysis = ''
      analyse "reflection-comp" python3 ${compare}
    '';
  } benchmark env;
}
