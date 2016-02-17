{ shared, tools, emma, mkAnalysis, python}:
{
  
  # Emma, dynammic reachable methods
  emma = env: benchmark: mkAnalysis {
    inherit env;
    name = "reachable-methods-emma-${benchmark.name}";
    tools = [ emma benchmark.java.jdk python];
    emma = emma;
    inputargs = (builtins.elemAt benchmark.inputs 0).args;
    inherit (benchmark) mainclass build libraries data;
    analysis = ''
      source $utils/tools
      source $stdenv/setup
      
      clp=`toClasspath $build $libraries`
      args=`evalArgs $inputargs`
      runHook setup
      echo "$args"

      analyse "emma" java -cp $emma/lib/jars/emma.jar:$emma/lib/jars/emma_ant.jar emmarun\
          -r xml -Dreport.depth=method -cp $clp $mainclass $args

      python2.7 ${./emma-parse.py} coverage.xml > ../methods.txt
    '';
  };

  # Petablox with the external refelction handeling
  petablox-external = shared.petablox {
    logicblox = null; # tools.logicblox-4_2_0;
    petablox = tools.petablox;
    name = "reachable-methods";
    reflection = "external";
    subanalyses = [ 
      "cipa-0cfa-dlog" 
    ];
    tools = [ python ];
    postprocessing = ''
      python2.7 ${./petablox-parse.py} sandbox/petablox_output/methods.txt > methods.txt
    '';
  };


}


