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
  petablox = shared.petablox {
    name = "deadlock";
    petablox = petablox_;
    subanalyses = ["cipa-0cfa-dlog" "deadlock-java"];
    reflection = "external";
  };
  
  overview = 
    utils.liftL (utils.overview "deadlock") 
      [ jchord ];
}

