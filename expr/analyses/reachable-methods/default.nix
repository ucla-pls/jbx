{ shared
, utils
, petablox
, doop
, emma
, python
, logicblox-4_3_6_3
, python3
, unzip
, javaq
, soot
, stdenv
, wala
}:
let
  emma_ = emma;
  soot_ = soot;
  wala_ = wala;
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

  doopCI = shared.doop { 
    subanalysis = "context-insensitive-plusplus";
    doop = doop;
    ignoreSandbox = true;
    tools = [ python ];
    postprocess = ''
      if [ -f $sandbox/out/context-insensitive-plusplus/0/database/Reachable.csv ]
      then
        python2.7 ${./petablox-parse.py} $sandbox/out/context-insensitive-plusplus/0/database/Reachable.csv > $out/upper
      fi
      rm -r "$sandbox"
    '';
  };
  
  wiretap = shared.wiretap 420 {
    settings = [
      { name = "wiretappers";     value = "EnterMethod";      }
      { name = "recorder";        value = "ReachableMethods"; }
      { name = "ignoredprefixes"; value = "edu/ucla/pls/wiretap,java"; }
    ];
    postprocess = ''
      sort -u $sandbox/_wiretap/reachable.txt > $out/lower
      '';
    };

  soot = b: 
    let sootext = stdenv.mkDerivation { 
        name = "reachable";
        buildInputs = [ b.java.jdk ];
        phases = "installPhase";
        installPhase = ''
          mkdir $out
          cp ${./SootReachableMethod.java} SootReachableMethod.java
          javac -cp ${soot_}/share/java/soot.jar SootReachableMethod.java -d $out
        '';
      };
    in utils.mkAnalysis {
      name = "soot-reachable-method";
      tools = [ b.java.jdk python ];
      soot = soot_;
      timelimit = 1800;
      analysis = ''
        analyse "soot" java -cp $soot/share/java/soot.jar:${sootext}\
          SootReachableMethod\
          -pp -w -cp $classpath -f n -p cg.spark on\
          -app $mainclass
      '';
      postprocess = ''
        if [ -f $sandbox/reachable-methods.txt ]
        then
            python2.7 ${./petablox-parse.py} $sandbox/reachable-methods.txt > $out/upper
        fi
      '';
  } b ;

  wala = b: 
    let walaext = stdenv.mkDerivation { 
        name = "reachable";
        buildInputs = [ b.java.jdk ];
        phases = "installPhase";
        installPhase = ''
          mkdir $out
          cp ${./WalaReachableMethod.java} WalaReachableMethod.java
          javac -cp ${wala_}/share/java/core.jar:${wala_}/share/java/util.jar:${wala_}/share/java/shrike.jar WalaReachableMethod.java -d $out
        '';
      };
    in utils.mkAnalysis {
      name = "wala-reachable-method";
      tools = [ b.java.jdk python ];
      wala = wala_;
      timelimit = 1800;
      analysis = ''
        analyse "wala" java -cp ${wala_}/share/java/core.jar:${wala_}/share/java/util.jar:${wala_}/share/java/shrike.jar:${walaext}\
          WalaReachableMethod\
          -classpath $classpath \
          -exclude ${./WalaExclusions.txt} \
          -mainclass $mainclass
      '';
      postprocess = ''
        if [ -f $sandbox/reachable-methods.txt ]
        then
            cp $sandbox/reachable-methods.txt $out/upper
        fi
      '';
  } b ;

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
    timelimit = 420; # 7 minutes
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

       grep $times lower_counts | cut -d ' ' -f2 > lower_min
       cat lower_counts | cut -d ' ' -f2 > lower_max

       comm -23 lower_max upper > difference_max
       comm -23 lower_min upper > difference_min
     '';
     foreach = ''
        comm -23 $result/lower upper | wc -l >> counts
     '';
     collect = ''
        cat counts | xargs echo "${b.name}" "$(cat difference_max | wc -l)" "$(cat difference_min | wc -l)" > total
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

  compare = 
    let analyses = 
        { W = wiretapAll; 
          P = petabloxDynamic;
          D = doopCI; 
          S = soot; 
          A = wala; 
        };
    in
     benchmark:
     env:
     utils.liftL (
       results: 
       utils.mkStatistics { 
        name = "library-reachable-method" + "+" + benchmark.name;
        tools = [ python3 ];
        collect = ''
          cd $out;
          python3 ${./to-json.py} ${world benchmark env} ${builtins.toString
   (map (name: name + ":" + (analyses.${name} benchmark env)) (builtins.attrNames analyses))
        } > compare.json'';
       } results
     ) (builtins.attrValues analyses) benchmark env;
 

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
