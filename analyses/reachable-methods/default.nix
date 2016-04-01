{ shared, utils, petablox, emma, python, logicblox-4_3_6_3}:
let 
  emma_ = emma; 
  inherit (utils) mkDynamicAnalysis onAllInputs;
in rec {
  # Emma, dynammic reachable methods
  emma = mkDynamicAnalysis {
    name = "emma";
    tools = [ python ];
    emma = emma_;
    timelimit = 420; # 7 minutes
    analysis = ''
      analyse "emma" java \
        -cp $emma/lib/jars/emma.jar:$emma/lib/jars/emma_ant.jar emmarun \
        -r xml -Dreport.depth=method \
        -cp $classpath $mainclass $args
    '';
    postprocess = "python2.7 ${./emma-parse.py} $sandbox/coverage.xml | sort > $out/must";
  };

  emmaAll = onAllInputs emma {};

  # Petablox with the external reflection handeling
  petabloxExternal = shared.petablox {
    petablox = petablox;
    logicblox = logicblox-4_3_6_3;
    name = "external";
    reflection = "external";
    subanalyses = [ "cipa-0cfa-dlog" ];
    tools = [ python ];
    postprocess = ''
      python2.7 ${./petablox-parse.py} $sandbox/petablox_output/methods.txt > $out/may
    '';
  };
  
  # Petablox with the dynamic reflection handeling
  petabloxDynamic = shared.petablox {
    petablox = petablox;
    # logicblox = logicblox-4_3_6_3;
    name = "dynamic";
    reflection = "dynamic";
    subanalyses = [ "cipa-0cfa-dlog" ];
    tools = [ python ];
    postprocess = ''
      python2.7 ${./petablox-parse.py} $sandbox/petablox_output/methods.txt > $out/may
    '';
  };

  overview = utils.liftL (utils.overview "reachable-methods") [ 
    petabloxExternal 
    petabloxDynamic
    emmaAll
  ];

}
