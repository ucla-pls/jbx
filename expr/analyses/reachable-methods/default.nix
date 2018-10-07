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
, jq
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
  
  doopCI_ = shared.doop { 
    subanalysis = "context-insensitive";
    doop = doop;
    ignoreSandbox = false;
    tools = [ python ];
    postprocess = ''
      if [ -f $sandbox/out/context-insensitive-plusplus/0/database/Reachable.csv ]
      then
        python2.7 ${./petablox-parse.py} $sandbox/out/context-insensitive-plusplus/0/database/Reachable.csv > $out/upper
      fi
    '';
  };

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
    tools = [ javaq jq ];
    timelimit = 420;
    analysis = ''
      analyse "reachable-methods-world" javaq --cp=$classpath > javaq.json
      jq '.name as $name | .methods[] | $name + "." + .' -r javaq.json | sed 's|<init>|"<init>"|;s|<clinit>|"<clinit>"|' > $out/upper
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
        { W = wiretapAnalyser (utils.overview "static-rm" [petabloxDynamic doopCI soot wala]) world; 
          P = petabloxDynamic;
          # D = doopCI; 
          S = soot; 
          A = wala; 
        };
    in
     benchmark:
     env:
     utils.cappedOverview "reachable-methods" world (builtins.attrValues analyses) {
       tools = [ python3 ];
       after = ''
          python3 ${./to-json.py} ${world benchmark env} ${builtins.toString
	    (map (name: name + ":" + (analyses.${name} benchmark env)) 
            (builtins.attrNames analyses))
          } > compare.json
	  python3 ${./firstlost.py} ${analyses.W benchmark env}/unsoundness0
	  ln -s ${benchmark.build} program
	  echo "${benchmark.mainclass}" | sed 's|\.|/|g' > mainclass
       '';
     } benchmark env;

  wiretapAnalyser = static: w: benchmark: env:
    let
      upper_ = "${static benchmark env}/upper";
      world_ = "${w benchmark env}/upper";
      wiretapa = shared.wiretap 420
        rec {
          settings = [
            { name = "wiretappers";       value = "EnterMethod,ReturnMethod";      }
            { name = "recorder";          value = "ReachableMethodsAnalyzer"; }
            { name = "ignoredprefixes";   value = "edu/ucla/pls/wiretap/,java/,sun/"; }
            { name = "overapproximation"; value = upper_; }
            { name = "world";             value = world_; }
          ];
          postprocess = ''
            if [[ -e  $sandbox/_wiretap/unsoundness ]]; then
              cp -r $sandbox/_wiretap/unsoundness $out
            fi
            cp -r $sandbox/_wiretap/reachable.txt $out/lower
            '';
        };
    in onAllInputs wiretapa {
      collect = ''
        var=0
        for f in $results; do
          if [[ -e $f/unsoundness ]]; then
            cp -r $f/unsoundness $out/unsoundness$var
            let "var=var+1"
          fi
        done
        ln -s ${benchmark.build} $out/benchmark
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
