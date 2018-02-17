{shared, jchord-2_0, petablox, utils, python, python3, eject}:
let
  jchord_ = jchord-2_0;
  petablox_ = petablox;
  loggingSettings = {
      depth = 0;
      timelimit = 122;
      ignoredprefixes = "org/mockito,org/powermock,edu/ucla/pls/wiretap,java,sun";
  };
in rec {
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
      filter = "unique,lockset";
      provers = ["none" "free" "valuesonly" "branchonly" "refsonly" "dirk" "rvpredict" "said" ];
      timelimit = 600;
      chunkSize = 1000;
      chunkOffset = 500;
      ignoreSandbox = true;
    };

  surveilOptions2 = {
      name = "deadlock";
      logging = loggingSettings;
      cmd = "deadlocks";
      filter = "unique,lockset";
      provers = ["none"];
      timelimit = 600;
      chunkSize = 1000;
      chunkOffset = 500;
      ignoreSandbox = true;
    };
  
  surveil2FlatAll = 
    utils.onAllInputs (shared.surveilFlat surveilOptions2) {};

  surveil = shared.surveil surveilOptions;
  surveilFlat = shared.surveilFlat surveilOptions;

  surveilWiretap =
    shared.wiretapSurveil loggingSettings;

  surveilAll =
    utils.onAllInputs surveil {};

  surveilRepeated =
     utils.repeated {
        times = 400;
        tools = [python3 eject];
        foreach = ''
          tail -n +2 "$result/times.csv" | sed 's/^.*\$//' >> times-tmp.csv
        '';
        collect = ''
          python3 ${./cyclestats.py} $name ${builtins.concatStringsSep "," surveilOptions.provers} $results | tee cycles.txt | column -ts,
        '';
     } (shared.surveilFlat surveilOptions);

  surveilRepeatedAll =
    benchmark:
      utils.lift (joinCycles (benchmark.name))
        (utils.onAllInputsS surveilRepeated)
        benchmark;

  joinCycles =
    name:
    utils.mkStatistics {
      name = name;
      tools = [eject];
      foreach = "cat $result/cycles.txt >> cycles.txt.tmp";
      collect = "sort -u cycles.txt.tmp | tee cycles.txt | column -ts,";
    };

  overview =
    utils.overview "deadlock" [
      jchord
      petablox
      surveilAll
    ];
}
