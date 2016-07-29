{ callPackage }:
rec {
  jchord = callPackage ./jchord { };
  petablox = callPackage ./petablox {
    inherit (logicblox) mkLogicBloxAnalysis;
  };
  logicblox = callPackage ./logicblox { };
  wiretap = callPackage ./wiretap {};
}

