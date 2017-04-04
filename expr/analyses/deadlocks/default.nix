{shared, jchord-2_0, petablox, utils, python}:
let
  jchord_ = jchord-2_0;
  petablox_ = petablox;
  loggingSettings = {
      depth = 0;
      timelimit = 120;
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

  surveil =
    shared.surveil {
      name = "deadlock";
      logging = loggingSettings;
      cmd = "deadlocks";
      filter = "unique,lockset";
      prover = "kalhauge";
      timelimit = 36000;
      chunkSize = 10000;
      chunkOffset = 5000;
    };

  surveilWiretap =
    shared.wiretapSurveil loggingSettings;

  surveilAll =
    utils.onAllInputs surveil {};

  overview =
    utils.overview "deadlock" [
      jchord
      petablox
      surveilAll
    ];
}
