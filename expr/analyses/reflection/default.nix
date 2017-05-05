{ utils, reachable-methods, python3 }:
let
  extract-methods = ./reflection-callers.sed;
  caller-methods = ./reflection-callers.sh;
  compare = ./reflection-comp.py;
in rec {
  reflection-caller-methods = benchmark: utils.mkAnalysis {
      name = "reflection-caller-methods";
      tools = [ benchmark.java.jdk ];
      analysis = ''
        analyse "reflection-caller-methods" \
            sed -nEf ${extract-methods} < <(javap -c -p -s -classpath $classpath $(jar -tf $classpath | grep "class$" | sed 's/\.class//g')) | \
            sort -u | tee "$out/upper"
      '';
  } benchmark;

  reflection-overview = utils.overview "reflection-overview" [
    reachable-methods.wiretapAll
    reachable-methods.petabloxDynamic
  ];

  comp = benchmark: env: utils.mkAnalysis {
    name = "reflection-comp";
    reflection_callers = (reflection-caller-methods benchmark env).out;
    reachable_methods = (reflection-overview benchmark env).out;
    tools = [ python3 ];
    analysis = ''
      analyse "reflection-comp" python3 ${compare}
    '';
  } benchmark env;
}
