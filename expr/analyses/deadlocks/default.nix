{shared, jchord-2_0, petablox, unzip, utils, python, python3, eject, calfuzzer, jq, tamiflex, zip}:
let
  jchord_ = jchord-2_0;
  petablox_ = petablox;
  loggingSettings = {
      depth = 10000;
      timelimit = 10;
      ignoredprefixes = "org/mockito,org/powermock,edu/ucla/pls/wiretap,java,sun";
  };
in rec {

  deadlockfuzzer = 
    benchmark:
    let cf = calfuzzer benchmark.java; in
    utils.mkDynamicAnalysis {
	name = "deadlockfuzzer";
       	timelimit = 1800;
        tools = [unzip zip];
        ext = ''
dontDumpClasses = false
dontNormalize = false
count = false
useDeclaredTypes = false
verbose = false
#outDir = /tmp/out

#NOTE: out of the following instruments, the "Booster" only supports the first four!
transformations =\
            de.bodden.tamiflex.playout.transformation.clazz.ClassForNameTransformation \
            de.bodden.tamiflex.playout.transformation.clazz.ClassNewInstanceTransformation \
            de.bodden.tamiflex.playout.transformation.constructor.ConstructorNewInstanceTransformation \
            de.bodden.tamiflex.playout.transformation.method.MethodInvokeTransformation
'';
#      de.bodden.tamiflex.playout.transformation.constructor.ConstructorToGenericStringTransformation \
#            de.bodden.tamiflex.playout.transformation.field.FieldGetTransformation \
#            de.bodden.tamiflex.playout.transformation.field.FieldSetTransformation \
#            de.bodden.tamiflex.playout.transformation.field.FieldToGenericStringTransformation \
#            de.bodden.tamiflex.playout.transformation.method.MethodToGenericStringTransformation \
        analysis = ''
           mkdir .tamiflex
           echo "$ext" > .tamiflex/poa.properties
	   
           echo "inDir = tmpclasses" >> .tamiflex/pia.properties
	   echo "dontNormalize = false" >> .tamiflex/pia.properties
	   echo "verbose = false" >> .tamiflex/pia.properties
           
	   timelimit=60 analyse "tamiflex" java -javaagent:${tamiflex}/share/java/poa.jar \
                 -Duser.home=$PWD \
                 -cp $classpath $mainclass $args 
          
           [ ! -e scratch ] || mv scratch/ tamiflex-scratch

	   export SOOT_JARS=${tamiflex}/share/java/soot.jar:${tamiflex}/share/java/polyglot.jar:${tamiflex}/share/java/jasmin.jar
           export JAVA_HOME="${benchmark.java.jdk}/jre"

           analyse "soot-test" java -Xmx10G -cp $SOOT_JARS soot.Main \
                -no-output-inner-classes-attribute \
                -keep-line-number -x javato -x edu.berkeley.cs.detcheck \
                -p cg reflection-log:out/refl.log \
                -w -app -p cg.spark enabled \
	        -cp $JAVA_HOME/lib/rt.jar:$JAVA_HOME/lib/jce.jar:out:${cf}/shared/java/calfuzzer.jar \
                -include org.apache. -include org.w3c. -main-class $mainclass -d tmpclasses $mainclass

           analyse "soot-run" java -javaagent:${tamiflex}/share/java/pia.jar=tmpclasses -cp ${cf}/shared/java/calfuzzer.jar:$classpath:tmpclasses \
                 -Duser.home=$PWD  \
                 $mainclass $args

           [ ! -e scratch ] || mv scratch/ soot-scratch
  
	   mv tmpclasses soot-tmpclasses

           analyse "inst" java -Xmx10G -cp $SOOT_JARS:${cf}/shared/java/calfuzzer.jar \
                javato.activetesting.instrumentor.InstrumentorForActiveTesting \
                -no-output-inner-classes-attribute \
                -keep-line-number -x javato -x edu.berkeley.cs.detcheck \
                -p cg reflection-log:out/refl.log \
                -w -app -p cg.spark enabled \
	        -cp $JAVA_HOME/lib/rt.jar:$JAVA_HOME/lib/jce.jar:out:${cf}/shared/java/calfuzzer.jar \
                -include org.apache. -include org.w3c. -main-class $mainclass -d tmpclasses $mainclass

           analyse "igoodlock" java -javaagent:${tamiflex}/share/java/pia.jar=tmpclasses -cp ${cf}/shared/java/calfuzzer.jar:$classpath:tmpclasses \
               -Duser.home=$PWD \
               -Djavato.ignore.methods=true \
               -Djavato.ignore.fields=true \
               -Djavato.ignore.allocs=true \
               -Djavato.activetesting.errorlist.file=error.list \
               -Djavato.activetesting.analysis.class=javato.activetesting.IGoodlockAnalysis \
               $mainclass $args
           
           [ ! -e scratch ]  || mv scratch/ igoodlock-scratch
           
           for line in $(sed 's/,/ /g' error.list); do
             analyse "deadlockfuzzer-$line" java -javaagent:${tamiflex}/share/java/pia.jar=tmpclasses -cp ${cf}/shared/java/calfuzzer.jar:$classpath:tmpclasses \
                 -Duser.home=$PWD \
                 -Djavato.ignore.methods=true \
                 -Djavato.ignore.fields=true \
                 -Djavato.ignore.allocs=true \
                 -Djavato.activetesting.errorid="$line" \
                 -Djavato.activetesting.analysis.class=javato.activetesting.DeadlockFuzzerAnalysis \
                 $mainclass $args
             [ ! -e scratch ]  || mv scratch/ $line-scratch
           done
        '';
    } benchmark;

  deadlockfuzzerRepeated =
     n:
     b:
     utils.repeated {
        times = n;
        tools = [python3 eject jq];
        foreach = ''
          tail -n +2 "$result/times.csv" | sed 's/^.*\$//' >> times.csv
          set +e
          grep "Real Deadlock Detected" "$result/stderr" | wc -l >> success.txt
	  set -e
          sed -e :a -e '/^Thread:/{N;/# END.*/{P;D};s/\n/::/;ta}' -e d "$result/stdout" | awk "\$0=\"$result,\"\$0" >> found.txt
        '';
        collect = ''
          # python3 ${./cyclestats.py} $name ${builtins.concatStringsSep "," surveilOptions.provers} $results | tee cycles.txt | column -ts,
          # python3 ${./average.py} $name sizes.txt times.csv > dyndata.csv
          sed 's/^/${b.name},/' times.csv > dyndata.csv
          sed 's/^/${b.name},/' success.txt > success.csv
        '';
     } deadlockfuzzer b;

  deadlockfuzzerAll =
    utils.onAllInputs deadlockfuzzer {};

  joinFuzzer =
    name:
    utils.mkStatistics {
      name = name;
      tools = [eject python3];
      foreach = ''
        #cat $result/cycles.txt >> cycles.txt.tmp
        cat $result/dyndata.csv >> dyndata.csv.tmp
        cat $result/success.csv >> success.csv.tmp
      '';
      collect = ''
        # sort -u cycles.txt.tmp | tee cycles.txt | column -ts,
        sort dyndata.csv.tmp > dyndata.csv
        sort success.csv.tmp > success.csv
      '';
    };

  deadlockfuzzerRepeatedAll =
    n:
    benchmark:
      utils.lift (joinFuzzer (benchmark.name))
        (utils.onAllInputsS (deadlockfuzzerRepeated n))
        benchmark;

  jchord = utils.after (shared.jchord {
    name = "deadlock";
    jchord = jchord_;
    subanalyses = ["deadlock-java"];
    reflection = "dynamic";
  }) {
    tools = [ python ];
    postprocess = ''
      python2.7 ${./jchord-parse.py} $sandbox/chord_output > $out/upper
    '';
  };

  petablox = utils.after (shared.petablox {
    name = "deadlock";
    petablox = petablox_;
    subanalyses = ["cipa-0cfa-dlog" "queryE" "deadlock-java"];
    reflection = "external";
    settings = [
      { name = "deadlock.exclude.nongrded"; value = "true"; }
      { name = "print.results"; value = "true"; }
    ];
  }) {
    tools = [ python ];
    postprocess = ''
      python2.7 ${./jchord-parse.py} $sandbox/petablox_output > $out/upper
    '';
  };

  surveilOptions = {
      name = "deadlock";
      logging = loggingSettings;
      cmd = "deadlocks";
      filter = "mhb,lockset";
      provers = ["none" "free" "dirk" "rvpredict" "said" ];
      timelimit = 600;
      solve-time = 60000;
      chunkSize = 10000;
      chunkOffset = 5000;
      ignoreSandbox = true;
    };

  dirkOptions = {
      name = "deadlock";
      logging = {
	      depth = -1;
	      timelimit = 1800;
	      ignoredprefixes = "org/mockito,org/powermock,edu/ucla/pls/wiretap,java,sun,org/dacapo/harness";
	  };
      cmd = "deadlocks";
      filter = "mhb,lockset";
      provers = ["none"];
      timelimit = 72000;
      solve-time = 60000;
      chunkSize = 500000;
      chunkOffset = 250000;
      verbose = true;
      ignoreSandbox = true;
    };
  
  dirk = 
    utils.onAllInputs dirkOne {};
  dirkOne = shared.surveil dirkOptions;
  dirkWiretapOne = shared.wiretapSurveil {} dirkOptions.logging;

  
  surveil = shared.surveil surveilOptions;
  surveilFlat = shared.surveilFlat surveilOptions;

  surveilWiretap =
    shared.wiretapSurveil {} loggingSettings;

  surveilAll =
    utils.onAllInputs surveil {};

  surveilRepeated =
     n:
     utils.repeated {
        times = n;
        tools = [python3 eject jq];
        foreach = ''
          tail -n +2 "$result/times.csv" | sed 's/^.*\$//' >> times.csv
	  cat "$result/history.size.txt" >> sizes.txt
        '';
        collect = ''
          python3 ${./cyclestats.py} $name ${builtins.concatStringsSep "," surveilOptions.provers} $results | tee cycles.txt | column -ts,
          python3 ${./average.py} $name sizes.txt times.csv > dyndata.csv
        '';
     } (shared.surveilFlat surveilOptions);

  surveilRepeatedAll =
    n:
    benchmark:
      utils.lift (joinCycles (benchmark.name))
        (utils.onAllInputsS (surveilRepeated n))
        benchmark;

  joinCycles =
    name:
    utils.mkStatistics {
      name = name;
      tools = [eject python3];
      foreach = ''
        cat $result/cycles.txt >> cycles.txt.tmp
        cat $result/dyndata.csv >> dyndata.csv.tmp
      '';
      collect = ''
        sort -u cycles.txt.tmp | tee cycles.txt | column -ts,
        sort dyndata.csv.tmp > dyndata.csv
      '';
    };

  overview =
    utils.overview "deadlock" [
      jchord
      petablox
      surveilAll
    ];
}
