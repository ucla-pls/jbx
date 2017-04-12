{ shared, utils, petablox, emma, python, logicblox-4_3_6_3, python3, unzip}:
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

  wiretap = b: e: shared.wiretap {
    settings = [
      { name = "wiretappers";     value = "EnterMethod";      }
      { name = "recorder";        value = "ReachableMethods"; }
      { name = "ignoredprefixes"; value = "edu/ucla/pls/wiretap,java"; }
    ];
    postprocess = ''
      comm -12 <(sort -u $sandbox/_wiretap/reachable.txt) "${world b e}/upper" > $out/lower
      '';
    } b e;

  wiretapAll = onAllInputs wiretap {};

  # Petablox with the external reflection handeling
  petabloxTamiflex = utils.after petabloxExternal {
    name = "tamiflex";
    ignoreSandbox = true;
    tools = [ python ];
    postprocess = ''
      if [ -f $sandbox/petablox_output/methods.txt ]
      then
        python2.7 ${./petablox-parse.py} $sandbox/petablox_output/methods.txt > $out/upper
      fi
    '';
  };

  # Petablox with the external reflection handeling
  petabloxExternal = b: e: shared.petablox {
    petablox = petablox;
    name = "external";
    reflection = "external";
    subanalyses = [ "cipa-0cfa-dlog" "reachable-methods" ];
    tools = [ python ];
    postprocess = ''
      if [ -f $sandbox/petablox_output/reachable-methods.txt ]
      then
        comm -12 "${world b e}/upper" >"$out/upper" \
          <(python2.7 ${./petablox-parse.py} $sandbox/petablox_output/reachable-methods.txt)
      fi
      '';
  } b e;

      # Petablox with the dynamic reflection handeling
  petabloxDynamic = b: e: shared.petablox {
    petablox = petablox;
    name = "dynamic";
    reflection = "dynamic";
    subanalyses = [ "reachable-methods" ];
    tools = [ python ];
    postprocess = ''
      if [ -f $sandbox/petablox_output/reachable-methods.txt ]
      then
        comm -12 "${world b e}/upper" >"$out/upper" \
          <(python2.7 ${./petablox-parse.py} $sandbox/petablox_output/reachable-methods.txt)
      fi
      '';
    } b e;

  world = benchmark: utils.mkAnalysis {
    name = "reachable-methods-world";
    tools = [ python3 unzip benchmark.java.jdk];
    timelimit = 420;
    analysis = ''
      analyse "reachable-methods-world" python3 ${./worldex.py} $build/ | sort -u > $out/upper
    '';
  } benchmark;

  overview = utils.overview "reachable-methods" [
    petabloxExternal
    world
    wiretapAll
  ];

}
