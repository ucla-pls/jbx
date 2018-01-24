{shared, utils, python, python3, eject}:
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
}
