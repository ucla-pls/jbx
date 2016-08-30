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
    postprocess = "python2.7 ${./emma-parse.py} $sandbox/coverage.xml | sort > $out/under";
  };

  emmaAll = onAllInputs emma {};


  wiretapped = shared.wiretap {
    settings = [
      { name = "wiretappers";     value = "EnterMethod";      }
      { name = "recorder";        value = "ReachableMethods"; }
      { name = "ignoredprefixes"; value = "edu/ucla/pls/wiretap,java/security,java/lang"; }
    ];
    postprocess = ''
      sort -u $sandbox/_wiretap/reachable.txt > $out/lower
      '';
    };

  wiretappedAll = onAllInputs wiretapped {};


  # Petablox with the external reflection handeling
  petabloxExternal = shared.petablox {
    petablox = petablox;
    name = "external";
    reflection = "external";
    subanalyses = [ "reachable-methods" ];
    tools = [ python ];
    postprocess = ''
      python2.7 ${./petablox-parse.py} $sandbox/petablox_output/reachable-methods.txt > $out/upper
      '';
  };

      # Petablox with the dynamic reflection handeling
  petabloxDynamic = shared.petablox {
    petablox = petablox;
    name = "dynamic";
    reflection = "dynamic";
    subanalyses = [ "reachable-methods" ];
    tools = [ python ];
    postprocess = ''
      python2.7 ${./petablox-parse.py} $sandbox/petablox_output/reachable-methods.txt > $out/upper
      '';
    };

  overview = utils.liftL (utils.overview "reachable-methods") [
    petabloxExternal
    petabloxDynamic
    wiretappedAll
  ];

}
