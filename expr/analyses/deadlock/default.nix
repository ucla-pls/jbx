{shared, jchord-2_0, petablox, utils, python}:
let 
  jchord_ = jchord-2_0;
  petablox_ = petablox;
in rec {
  jchord = utils.after (shared.jchord {
    name = "deadlock";
    jchord = jchord_;
    subanalyses = ["deadlock-java"];
    reflection = "dynamic";
  }) { 
    tools = [ python ];
    postprocess = ''
      python2.7 ${./jchord-parse.py} $sandbox/chord_output > $out/may
    '';
  };
  
  petablox = utils.after (shared.petablox {
    name = "deadlock";
    petablox = petablox_;
    subanalyses = ["cipa-0cfa-dlog" "queryE" "deadlock-java"];
    reflection = "external";
    settings = [
      { name = "deadlock.exclude.nongrded"; value = "true"; }
    ];
  }) { 
    tools = [ python ];
    postprocess = ''
      python2.7 ${./jchord-parse.py} $sandbox/petablox_output > $out/may
    '';
  };
  
  overview = 
    utils.liftL (utils.overview "deadlock") 
      [ jchord ];
}

