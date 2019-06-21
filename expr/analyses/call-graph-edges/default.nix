        { shared
, pkgs
, utils
, tools
, makeWrapper
, stdenv
, openjdk8
}:
rec {
  wala-call-graph-edges = 
    let wala = tools.wala; in
    java:
      stdenv.mkDerivation { 
        name = "wala-call-graph-edges";
        buildInputs = [ java makeWrapper ];
        phases = "installPhase";
        walajars = "${wala}/share/java/core.jar:${wala}/share/java/util.jar:${wala}/share/java/shrike.jar";
        installPhase = ''
         mkdir $out
         cp ${./WalaCallgraph.java} WalaCallgraph.java
         javac -cp $walajars WalaCallgraph.java -d $out
         mkdir $out/bin
         makeWrapper ${java}/bin/java $out/bin/wala-call-graph-edges \
          --add-flags -cp \
          --add-flags $walajars:$out\
          --add-flags walaOptions.WalaCallgraph\
        '';
      };
  wala-call-graph-edges8 = wala-call-graph-edges openjdk8;

  wala = { 
    reflection ? true,
    resolveinterfaces ? true,
    analysis ? "0cfa",
    }: b: 
    utils.mkAnalysis {
      name = "wala-cge-${analysis}-${(if reflection then "" else "no")
        + "reflect"}-${if resolveinterfaces then "intf" else "nointf"}";
      tools = [ (wala-call-graph-edges b.java.jdk) ];
      timelimit = 1800;
      analysis = ''
        analyse "$name" wala-call-graph-edges \
          -classpath $classpath -mainclass $mainclass \
          -output edges.txt \
          -analysis ${analysis} \
          -reflection ${if reflection then "true" else "false"} \
          -resolveinterfaces ${if resolveinterfaces then "true" else "false"}
      '';
      postprocess = ''
        if [ -f $sandbox/edges.txt ]
        then
            sed 1d $sandbox/edges.txt | sort > $out/upper
        fi
      '';
  } b ;

  wala-0cfa-noreflect = 
    wala { 
      reflection = false;
      resolveinterfaces = true;
      analysis = "0cfa";
    };
  
  wala-0cfa-reflect = 
    wala { 
      reflection = true;
      resolveinterfaces = true;
      analysis = "0cfa";
    };

  wala-1cfa-noreflect = 
    wala { 
      reflection = false;
      resolveinterfaces = true;
      analysis = "1cfa";
    };
  
  wala-1cfa-reflect = 
    wala { 
      reflection = true;
      resolveinterfaces = true;
      analysis = "1cfa";
    };
  
  wala-rta-noreflect = 
    wala { 
      reflection = false;
      resolveinterfaces = true;
      analysis = "rta";
    };

  wala-0cfa-noreflect-nointf = 
    wala { 
      reflection = false;
      resolveinterfaces = false;
      analysis = "0cfa";
    };
  
  doop = { reflection ? true }: 
  b: e:
  shared.doop { 
    subanalysis = "context-insensitive";
    doop = tools.doop;
    tools = [ pkgs.python3 ];
    ignoreSandbox = true;
    reflection = reflection;
    timelimit = 1800;
    postprocess = ''
        file="$sandbox/out/context-insensitive/0/database/CallGraphEdge.csv"
        if [ -f "$file" ]
        then
          ln -s "${decompile b e}" $out/decompiled
          python ${./doop-parse.py} $out/doop-formatted.csv $file
          python ${./mapping.py} $out/upper $out/decompiled/callsites.csv $out/doop-formatted.csv
        fi
    '';
  } b e;

  doop-noreflect = doop { reflection = false; };
  doop-reflect = doop { reflection = true; };

  doop-noreflect-closed = close-graph doop-noreflect;

  decompile = b: utils.mkAnalysis {
    name = "decompile";
    tools = [ b.java.jdk tools.javaq pkgs.python3 ];
    timelimit = 300;
    analysis = ''
      analyse "decompile" javaq --cp $classpath decompile > decompiled.json
      analyse "list-methods" javaq --cp $classpath list-methods > methods.txt
    '';
    postprocess = ''
      mv "$sandbox/decompiled.json" "$out"
      mv "$sandbox/methods.txt" "$out"
      python ${./callsites.py} < $out/decompiled.json > "$out/callsites.csv"
    '';
  } b;

  stdlib-methods = java: stdenv.mkDerivation {
    name = "stdlib-methods";
    buildInputs = [ tools.javaq java ];
    phases = "installPhase";
    installPhase = ''
      javaq --cp /dev/null --stdlib --jre ${java}/jre list-methods > $out
    '';
  };
  stdlib-methods8 = stdlib-methods pkgs.openjdk8;


  wiretap-shared = 
    { ignoredprefixes ? "edu/ucla/pls/wiretap,java,sun"
    , timelimit ? 420
    }:
    shared.wiretap timelimit {
      settings = [
      { name = "recorder"; value = "PointsTo"; }
      { name = "ignoredprefixes";  value = ignoredprefixes; }
      ];
      tools = [ tools.wiretap-pointsto ];
      postprocess = ''
        wiretap-pointsto $sandbox/_wiretap > $out/lower 
        rm -rf $sandbox/_wiretap/pointsto
      '';
    };

  wiretap = wiretap-shared {};
  
  wiretapAll = utils.onAllInputs wiretap {};

  soot-call-graph-edges = 
    let soot = tools.soot; in
    java:
      stdenv.mkDerivation { 
        name = "soot-call-graph-edges";
        buildInputs = [ java makeWrapper ];
        phases = "installPhase";
        sootjars = "${soot}/share/java/soot.jar";
        installPhase = ''
         mkdir $out
         cp ${./SootCallgraph.java} SootCallgraph.java
         javac -cp $sootjars SootCallgraph.java -d $out
         mkdir $out/bin
         makeWrapper ${java}/bin/java $out/bin/$name \
          --add-flags -cp \
          --add-flags $sootjars:$out\
          --add-flags SootCallgraph\
        '';
      };
  soot-call-graph-edges8 = soot-call-graph-edges openjdk8;

  soot = b: e: 
    utils.mkAnalysis {
      name = "soot-cge";
      tools = [ pkgs.python3 (soot-call-graph-edges b.java.jdk) ];
      timelimit = 1800;
      analysis = ''
        analyse "$name" soot-call-graph-edges \
          callgraph.txt \
          $mainclass \
          -p cg.spark on \
          -pp -w -f n -app \
          -process-dir $classpath -allow-phantom-refs 
      '';
      postprocess = ''
        if [ -f $sandbox/callgraph.txt ]
        then
           ln -s "${decompile b e}" $out/decompiled
           python ${./soot-parse.py} $out/soot-formatted.csv $sandbox/callgraph.txt
           python ${./mapping.py} $out/upper $out/decompiled/callsites.csv $out/soot-formatted.csv
#           cp $sandbox/callgraph.txt $out/upper  
        fi
      '';
  } b e;

  # Build the petablox analysis 
  petablox-call-graph-edges = 
    let petablox = tools.petablox-gt-develop; in
    java:
      stdenv.mkDerivation {
        name = "petablox-call-graph-edges";
        buildInputs = [ java makeWrapper ];
        phases = "installPhase";
        petabloxjars = "${petablox}/share/java/petablox.jar"; # assume this is where it is
        installPhase = ''
          mkdir $out
          cp ${./PetabloxCallgraph.java} PetabloxCallgraph.java
          javac -cp $petabloxjars PetabloxCallgraph.java -d $out
          mkdir $out/bin 
          makeWrapper ${java}/bin/java $out/bin/$name \
            --add-flags -cp \
            --add-flags $petabloxjars:$out\
            --add-flags PetabloxCallgraph\
        '';
      };
  petablox-call-graph-edges8 = petablox-call-graph-edges openjdk8;

  petablox = { ctxt_sensitive ? false }: 
    b: e: 
    shared.petablox {
      petablox = tools.petablox-gt-develop;
      subanalyses =[ "petablox-cg-java" ];
      tools = [ pkgs.python3 (petablox-call-graph-edges b.java.jdk) ];
      timelimit = 1800;
      reflection = "none";
      settings = [
         {name = "cs";  value = if ctxt_sensitive then "1" else "0"; }
         {name = "kcfa.k"; value = "1"; }
         {name = "inst.ctxt.kind"; value = if ctxt_sensitive then "cs" else "ci"; }
         {name = "stat.ctxt.kind"; value = if ctxt_sensitive then "cs" else "ci"; }
         {name = "outfile"; value = "callgraph.txt";}
         {name = "ext.java.analysis.path"; value = "${(petablox-call-graph-edges b.java.jdk)}"; } 
      ];
      postprocess = ''
        if [ -f $sandbox/petablox_output/callgraph.txt ]
        then
           ln -s "${decompile b e}" $out/decompiled
           python ${./soot-parse.py} $out/petablox-formatted.csv $sandbox/petablox_output/callgraph.txt
           python ${./mapping.py} $out/upper $out/decompiled/callsites.csv $out/petablox-formatted.csv
           # cat $sandbox/petablox_output/callgraph.txt | sort > $out/upper
        fi
      '';
    } b e;

  petablox-0cfa = petablox { ctxt_sensitive = false; };
  petablox-1cfa = petablox { ctxt_sensitive = true; };

  close-graph = a: b: e:
    utils.postprocess {
      name = "closed";
      tools = [ pkgs.python3 ];
      ignoreSandbox = true;
      postprocess = ''
        mv upper upper.before
        mkdir closed
        cd closed
        ln -s ${decompile b e} decompiled
        python ${./callgraph.py} \
          --stdlib ${stdlib-methods b.java.jdk} \
          --callsites decompiled/callsites.csv \
          --methods decompiled/methods.txt \
          < ../upper.before > ../upper 2>warnings
      '';
    } (a b e);


  all = [
    wala-0cfa-noreflect 
    wala-0cfa-reflect 
    wala-1cfa-noreflect 
    wala-1cfa-reflect 
    wala-rta-noreflect  
    wala-0cfa-noreflect-nointf 
    doop-noreflect 
    doop-reflect 
    petablox-0cfa
    petablox-1cfa 
    soot
  ];

  afew = [ 
    wala-0cfa-noreflect 
    doop-reflect 
  ];

  combined = b:
    utils.liftL ( 
      utils.mkStatistics { 
        name = "call-graph-edges+${b.name}"; 
        foreach = ''
          echo "In $result" >> warnings
          cat $result/closed/warnings >> warnings
        '';
    }) 
    (builtins.map close-graph all) b;
}

