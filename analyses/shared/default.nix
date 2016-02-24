{ callPackage, mkAnalysis }:
rec {
  jchord = callPackage ./jchord {
    inherit mkAnalysis;
  };
  petablox = callPackage ./petablox {
    inherit (logicblox) mkLogicBloxAnalysis;
    inherit mkAnalysis;
  };
  logicblox = callPackage ./logicblox { 
    inherit mkAnalysis;
  };
}

