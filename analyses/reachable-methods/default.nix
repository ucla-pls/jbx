{ shared, compose, tools, emma, mkAnalysis, python, postprocessors}:
let emma_ = emma; in
rec {
  
  # Emma, dynammic reachable methods
  emma = env: benchmark: input: mkAnalysis {
    inherit env;
    name = "reachable-methods-emma-${benchmark.name}-${input.name}";
    tools = [ emma_ benchmark.java.jdk python];
    emma = emma_;
    timelimit = 420; # 7 minutes
    inputargs = input.args;
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

  emma-all = env: benchmark: 
    let analyses = map (emma env benchmark) benchmark.inputs;
    in compose analyses { 
      sign = "-";
      name = "reachable-methods-emma-${benchmark.name}";
      foreach = ''cat $result/methods.txt >> methods.txt'';
    };

  # Petablox with the external refelction handeling
  petablox-external = shared.petablox {
    logicblox = null; # tools.logicblox-4_2_0;
    petablox = tools.petablox;
    sign = "+";
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

  overview = postprocessors.overview { 
    analyses = [ petablox-external emma-all];
    name = "reachable-methods";
    resultfile = "methods.txt";
  };
}


