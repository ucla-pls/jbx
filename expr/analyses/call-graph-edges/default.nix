{ shared
, pkgs
, utils
, tools
, makeWrapper
, stdenv
, openjdk8
, javaq
}:
rec {
  wala-call-graph-edges = 
    let wala = tools.wala; in
    java:
      stdenv.mkDerivation { 
        name = "wala-call-graph-edges";
        buildInputs = [ java makeWrapper ];
        phases = "installPhase";
        installPhase = ''
         mkdir $out
         cp ${./WalaCallgraph.java} WalaCallgraph.java
         javac -cp ${wala}/share/java/core.jar:${wala}/share/java/util.jar:${wala}/share/java/shrike.jar WalaCallgraph.java -d $out
         mkdir $out/bin
         makeWrapper ${java}/bin/java $out/bin/wala-call-graph-edges \
          --add-flags -cp \
          --add-flags ${wala}/share/java/core.jar:${wala}/share/java/util.jar:${wala}/share/java/shrike.jar:$out\
          --add-flags walaOptions.WalaCallgraph\
        '';
      };
  wala-call-graph-edges8 = wala-call-graph-edges openjdk8;

  wala = { name, args }: b: 
    utils.mkAnalysis {
      name = "wala-call-graph-edges-${name}";
      tools = [ (wala-call-graph-edges b.java.jdk) ];
      timelimit = 1800;
      analysis = ''
        analyse "wala-${name}" wala-call-graph-edges -classpath $classpath -mainclass $mainclass -output edges.txt ${args}
      '';
      postprocess = ''
        if [ -f $sandbox/edges.txt ]
        then
            sed 1d $sandbox/edges.txt | sort > $out/upper
        fi
      '';
  } b ;

  wala-0cfa-noreflect = wala { name = "0cfa-noreflect"; args = "-analysis 0cfa -reflection false -resolveinterfaces true";};
  wala-0cfa-reflect = wala { name = "0cfa-noreflect"; args = "-analysis 0cfa -reflection true -resolveinterfaces true";};
  wala-1cfa-noreflect = wala { name = "0cfa-noreflect"; args = "-analysis 1cfa -reflection false -resolveinterfaces true";};
  wala-1cfa-reflect = wala { name = "0cfa-noreflect"; args = "-analysis 1cfa -reflection true -resolveinterfaces true";};
  wala-rta-noreflect = wala { name = "0cfa-noreflect"; args = "-analysis rta -reflection false -resolveinterfaces true";};
  wala-0cfa-noreflect-no_interface_resolution = wala { name = "0cfa-noreflect"; args = "-analysis 0cfa -reflection false -resolveinterfaces false";};

  doop = reflection_: shared.doop { 
    subanalysis = "context-insensitive";
    doop = tools.doop;
    tools = [ pkgs.python3 javaq];
    ignoreSandbox = true;
    reflection = reflection_;
    timelimit = 1800;
    postprocess = ''
      file="$sandbox/out/$subanalysis/0/database/Reachable.csv"
      if [ -f "$file" ]
      then
        cp "$file" $out/DoopReachable.csv
        javaq --format=json-full --cp=$classpath > $out/javaq.json
        python ${./doop-parse.py} $out/upper $out/javaq.json $out/DoopReachable.csv 
      fi
      rm -r $sandbox
    '';
  };

  doop-noreflect = doop false;
  doop-reflect = doop true;


#  petabloxDefault = shared.petablox {
#    petablox = petablox;
#    name = "none";
#    reflection = "none";
#    timelimit = 1800;
#    subanalyses = [ "reachable-methods" ];
#    tools = [ python ];
#    postprocess = ''
#      if [ -f $sandbox/petablox_output/edges.txt ]
#      then
#          $sandbox/petablox_output/edges.txt > $out/upper #python ${./petablox-parse.py} $sandbox/petablox_output/edges.txt > $out/upper
#          rm -r "$sandbox/petablox_output/bddbddb"
#      fi
#      rm -r $sandbox
#      '';
#    };


#  doop-pp = b: e: 
#    postprocess { 
#      tools = [ pkgs.python javaq ];
#      postprocess = ''
#          javaq --format=json --cp=$classpath > $out/javaq.json
#          python doop-parse.py $out/javaq.json $out/DoopReachable.csv 
#      '';
#  } (doop-noreflect b e);

    
#      stdenv.mkDerivation {
#        name = "javaq";
#        buildInputs = [ ];
#        phases = "installPhase";
#        installPhase = ''
#        javaq --format json --cp  >         

#      };
}

