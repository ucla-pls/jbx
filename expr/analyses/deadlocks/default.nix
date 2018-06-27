{shared, jchord-2_0, petablox, utils, python, python3, eject}:
let
  jchord_ = jchord-2_0;
  petablox_ = petablox;
  loggingSettings = {
      depth = 10000;
      timelimit = 10;
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
      logging = loggingSettings;
      cmd = "deadlocks";
      filter = "mhb,lockset";
      provers = ["dirk"];
      timelimit = 600;
      solve-time = 60000;
      chunkSize = 10000;
      chunkOffset = 5000;
      ignoreSandbox = false;
    };
  
  dirk = 
    utils.onAllInputs (shared.surveil dirkOptions) {};
  
  surveil = shared.surveil surveilOptions;
  surveilFlat = shared.surveilFlat surveilOptions;

  surveilWiretap =
    shared.wiretapSurveil loggingSettings;

  surveilAll =
    utils.onAllInputs surveil {};

  surveilRepeated =
     n:
     utils.repeated {
        times = n;
        tools = [python3 eject];
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
        sort -u dyndata.csv.tmp > dyndata.csv
      '';
    };

  overview =
    utils.overview "deadlock" [
      jchord
      petablox
      surveilAll
    ];
}
