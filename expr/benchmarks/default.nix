{ callPackage, utils }:
rec {
  dacapo = callPackage ./dacapo {};
  baseline = callPackage ./baseline {};
  independent = callPackage ./dacapo {};
  java-grande = callPackage ./java-grande {};
  sir = callPackage ./sir {};
  jaConTeBe = callPackage ./JaConTeBe {};

  autogen = callPackage ./auto-generated {};

  # All benchmarks should be registered here
  all =  baseline.all
      ++ dacapo.all
      ++ java-grande.all
      ++ sir.all
      ++ jaConTeBe.all
      ++ autogen.all;

  byName = utils.byName all;
  byTag = utils.byTag all;
}
