{ callPackage, utils}:
let
  inherit (utils) callBenchmark fetchprop;
  # Same as: 
  # callBenchmark = utils.callBenchmark;
  # fetchprop = utils.fetchprop;
  java-grande-src = fetchprop {
     url="java_grande.tar.gz";
     sha256="10mfasrbga7zvf51pybvp1cwwllm26i6c2v6w0gyay69nsb5sh91"; 
  };
in rec {
  src = java-grande-src;

  monte-carlo = callBenchmark ./monte-carlo { inherit java-grande-src; };
  ray-tracer = callBenchmark ./ray-tracer { inherit java-grande-src; };
  mol-dyn = callBenchmark ./mol-dyn { inherit java-grande-src; };

  all = [
    # monte-carlo
    # ray-tracer
    # mol-dyn
  ];
}
