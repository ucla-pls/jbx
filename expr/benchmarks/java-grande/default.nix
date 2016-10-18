{ callPackage, utils}:
let
  # Same as: callBenchmark = utils.callBenchmark;
  inherit (utils) callBenchmark;
  java-grande-src = fetchprop {
     url="java_grande.tar.gz";
     md5="2d2cd274632347353c9ab806b3384c47";
  };
in rec {
  java-grande-src = java-grande-src;

  monte-carlo = callBenchmark ./monte-carlo { inherit java-grande-src; };
  ray-tracer = callBenchmark ./ray-tracer { inherit java-grande-src; };
  mol-dyn = callBenchmark ./mol-dyn { inherit java-grande-src; };

  all = [
    monte-carlo
    ray-tracer
    mol-dyn
  ];
}
