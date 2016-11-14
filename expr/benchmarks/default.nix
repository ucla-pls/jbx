{ callPackage, utils }:
rec {
  dacapo = callPackage ./dacapo {};
  baseline = callPackage ./baseline {};
  independent = callPackage ./dacapo {};
  autogen = callPackage ./auto-generated {};
  java-grande = callPackage ./java-grande {};

  # All benchmarks should be registered here
  all =  baseline.all
      ++ dacapo.all
      ++ java-grande.all
      ++ autogen.all;

  byName = utils.byName all;
  byTag = utils.byTag all;
}
