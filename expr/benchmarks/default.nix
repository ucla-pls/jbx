{ callPackage, utils }:
rec {
  dacapo = callPackage ./dacapo {};
  baseline = callPackage ./baseline {};
  independent = callPackage ./dacapo {};
  java-grande = callPackage ./java-grande {};
  sir = callPackage ./sir {};

  autogen = callPackage ./auto-generated {};

  # All benchmarks should be registered here
  all =  baseline.all
      ++ dacapo.all
      ++ java-grande.all
      ++ sir.all
      ++ autogen.all;

  byName = utils.byName all;
  byTag = utils.byTag all;
}
