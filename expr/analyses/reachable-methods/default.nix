{ shared, utils, petablox, emma, python, logicblox-4_3_6_3, python3, unzip, javaq }:
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

  wiretap = shared.wiretap {
    settings = [
      { name = "wiretappers";     value = "EnterMethod";      }
      { name = "recorder";        value = "ReachableMethods"; }
      { name = "ignoredprefixes"; value = "edu/ucla/pls/wiretap,java"; }
    ];
    postprocess = ''
      sort -u $sandbox/_wiretap/reachable.txt > $out/lower
      '';
    };

  wiretapAll = onAllInputs wiretap {};

  wiretapFlat = benchmark: env: input:
    let
      world_ = "${world benchmark env}/upper";
    in shared.wiretap {
    settings = [
      { name = "wiretappers";     value = "EnterMethod";      }
      { name = "recorder";        value = "ReachableMethods"; }
      { name = "ignoredprefixes"; value = "edu/ucla/pls/wiretap,java"; }
    ];
    postprocess = ''
      comm -12 "${world_}" <(sort -u $sandbox/_wiretap/reachable.txt) > $out/lower
      rm -r $out/sandbox
      rm $out/tops
      '';
    } benchmark env input;


  wiretapFlatAll = onAllInputs wiretapFlat {};

  wiretapRepeated = b: e: i:
    let
      upper_ = "${petabloxDynamic b e}/upper";
      world_ = "${world b e}/upper";
    in utils.repeated {
     times = 10;
     before = ''
       comm -12 ${world_} ${upper_} > upper
       echo "$results" \
         | sed 's/\(repeat[0-9]*\) */\1\/lower\n/g' \
         | xargs sort -m \
         | uniq -c \
         | sed 's/^ *//' > lower_counts

       grep $times lower_counts | cut -d ' ' -f2 > lower

       comm -23 lower upper > difference
     '';
     foreach = ''
        comm -23 $result/lower upper | wc -l >> counts
     '';
     collect = ''
        cat counts | xargs echo "${b.name}" "$(cat difference | wc -l)" > total
     '';
  } wiretapFlat b e i;

  wiretapRepeatedAll = utils.onAllInputsS wiretapRepeated;

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
  petabloxExternal = shared.petablox {
    petablox = petablox;
    timelimit = 1800;
    name = "external";
    reflection = "external";
    subanalyses = [ "cipa-0cfa-dlog" "reachable-methods" ];
    tools = [ python ];
    postprocess = ''
      if [ -f $sandbox/petablox_output/reachable-methods.txt ]
      then
          python2.7 ${./petablox-parse.py} $sandbox/petablox_output/reachable-methods.txt > $out/upper
          rm -r "$sandbox/petablox_output/bddbddb"
      fi
      '';
  };

  # Petablox with the dynamic reflection handeling
  petabloxDynamic = shared.petablox {
    petablox = petablox;
    name = "dynamic";
    reflection = "dynamic";
    timelimit = 1200;
    subanalyses = [ "reachable-methods" ];
    tools = [ python ];
    postprocess = ''
      if [ -f $sandbox/petablox_output/reachable-methods.txt ]
      then
          python2.7 ${./petablox-parse.py} $sandbox/petablox_output/reachable-methods.txt > $out/upper
          rm -r "$sandbox/petablox_output/bddbddb"
      fi
      rm -r $sandbox
      '';
    };

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
    petabloxDynamic
    petabloxTamiflex
    wiretapAll
  ];

  comp = utils.cappedOverview "library-reachable-method" world [
    wiretapAll
    petabloxDynamic
  ];

  wiretapAnalyser = benchmark: env:
    let
      upper_ = "${petabloxDynamic benchmark env}/upper";
      world_ = "${world benchmark env}/upper";
    in onAllInputs (shared.wiretap (rec {
    settings = [
      { name = "wiretappers";       value = "EnterMethod,ReturnMethod";      }
      { name = "recorder";          value = "ReachableMethodsAnalyzer"; }
      { name = "ignoredprefixes";   value = "edu/ucla/pls/wiretap/,java/,sun/,javax/,com/sun/,com/ibm/,org/xml/,org/w3c/,apple/awt/,com/apple/"; }
      { name = "overapproximation"; value = upper_; }
      { name = "world";             value = world_; }
    ];
    timelimit = 840;
    postprocess = ''
      if [[ -e  $sandbox/_wiretap/unsoundness ]]; then
        cp -r $sandbox/_wiretap/unsoundness $out
        cp -r $sandbox/_wiretap/reachable.txt $out/lower
      fi
      '';
    })) {
      collect = ''
        var=0
        for f in $results; do
          if [[ -e $f/unsoundness ]]; then
            cp -r $f/unsoundness $out/unsoundness$var
            let "var=var+1"
          fi
        done
        ln -s ${benchmark.build} $out/benchmark
        cp ${upper_} $out/upper
        cp ${world_} $out/world

        touch $out/phases
      '';
    } benchmark env;

  wiretapBucket = b: utils.after wiretapAnalyser {
    tools = [ javaq ];
    ignoreSandbox = true;
    java = b.java.jdk;
    inherit (b) mainclass build libraries;
    postprocess = ''
       classpath=`toClasspath $build $libraries`

       sed -e 's/\..*$//' unsoundness0/*.stack \
         | uniq \
         | javaq list-indirect-methods \
            --jre=$java/lib/openjdk/jre \
            --classpath=$classpath \
            > unsoundness0/indirect-methods.txt || true
    '';
  } b;

}
