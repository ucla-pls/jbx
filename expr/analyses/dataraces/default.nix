{shared, z3, tools, utils, python, python3, eject}:
let
  loggingSettings = {
      depth = 1000;
      timelimit = 122;
      ignoredprefixes = "org/mockito,org/powermock,edu/ucla/pls/wiretap,java,sun";
  };
in rec {
  surveilOptions = {
      name = "datarace";
      logging = loggingSettings;
      cmd = "dataraces";
      filter = "unique,lockset";
      provers = ["none" "free" "weak" "dirk" "rvpredict" "said" ];
      timelimit = 36000;
      chunkSize = 10000;
      chunkOffset = 5000;
    };

  surveil = shared.surveil surveilOptions;
  surveilFlat = shared.surveilFlat surveilOptions;

  surveilWiretap =
    shared.wiretapSurveil {} loggingSettings;

  surveilAll =
    utils.onAllInputs surveil {};

  rvp-instrument =
    benchmark:
    utils.mkAnalysis {
      name = "rvp-instrument";
      rvpredict = tools.rvpredict benchmark.java;
      tools = [ benchmark.java.jdk ];
      analysis = ''
       OPTIONS="-Xmx32g -Duser.dir=$PWD -Duser.home=$PWD"
       RVI=$rvpredict/share/java/rv-predict-inst.jar
       RVE=$rvpredict/share/java/rv-predict-engine.jar
       analyse "rv-instrument" java $OPTIONS -cp $RVI:$RVE:$classpath rvpredict.instrumentation.Main $mainclass -nosa
       mv tmp/record ../record
       mv RVDatabase.h2.db ../
      '';
    } benchmark ;

  rvpredict =
    benchmark:
    env:
    utils.mkDynamicAnalysis {
      name = "rvpredict";
      rvpredict = tools.rvpredict benchmark.java;
      inst = rvp-instrument benchmark env;
      tools = [ z3 ];
      analysis = ''
        echo $PWD
        OPTIONS="-Xmx32g -Duser.dir=$PWD -Duser.home=$PWD"
        RVE=$rvpredict/share/java/rv-predict-engine.jar
        RVL=$rvpredict/share/java/rv-predict-log.jar
        cp $inst/RVDatabase.h2.db .
        chmod +w RVDatabase.h2.db
        analyse "rv-record" java $OPTIONS \
           -cp $inst/record:$RVL:$RVE edu.uiuc.run.Main $mainclass $args < $stdin
        analyse "rv-predict" java $OPTIONS -cp $RVE NewRVPredict $mainclass
        grep "Race" ../rv-predict/stderr > ../lower
      '';
    } benchmark env;
}
