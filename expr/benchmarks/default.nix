{ callPackage, utils }:
rec {
  dacapo = callPackage ./dacapo {};
  baseline = callPackage ./baseline {};
  independent = callPackage ./dacapo {};
  njr-deadlocks = callPackage ./njr-deadlocks {};
  java-grande = callPackage ./java-grande {};
  sir = callPackage ./sir {};
  jaConTeBe = callPackage ./JaConTeBe {};
  rvpredict = callPackage ./rvpredict {};

  autogen = callPackage ./auto-generated {};

  # All benchmarks should be registered here
  all =  baseline.all
      ++ dacapo.all
      ++ java-grande.all
      ++ sir.all
      ++ jaConTeBe.all
      ++ autogen.all
      ++ njr-deadlocks.all
      ++ rvpredict.all
  ;

  byName = utils.byName all;
  byTag = utils.byTag all;
}
