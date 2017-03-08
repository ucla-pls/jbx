{ callPackage }:
rec {
  jchord = callPackage ./jchord { };
  petablox = callPackage ./petablox {
    inherit (logicblox) mkLogicBloxAnalysis;
  };
  logicblox = callPackage ./logicblox { };
  inherit (callPackage ./wiretap {})
    wiretap
    surveil
    surveilFlat
    wiretapSurveil
    ;
}
