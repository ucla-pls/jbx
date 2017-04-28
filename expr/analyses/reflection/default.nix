{ utils }:
let detector = ./reflection.sh; in 
{
  reflection = benchmark: utils.mkAnalysis {
      name = "reflection";
      tools = [ benchmark.java.jdk ];
      analysis = ''
        analyse "reflection" bash ${detector}
      '';
  } benchmark;
}
