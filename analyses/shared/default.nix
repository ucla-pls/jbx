{ callPackage, mkAnalysis }:
rec {
  jchord = callPackage ./jchord {
    inherit (logicblox) mkLogicBloxAnalysis;
    inherit mkAnalysis;
  };
  logicblox = callPackage ./logicblox { 
    inherit mkAnalysis;
  };
}

