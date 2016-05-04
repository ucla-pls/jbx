{ callPackage, utils }:
rec {
  dacapo = callPackage ./dacapo {};
  baseline = callPackage ./baseline {};
  independent = callPackage ./dacapo {};
  autogen = callPackage ./auto-generated {};
 
  # All benchmarks should be registered here
  all =  baseline.all 
      ++ dacapo.all
      ++ autogen.all;

  byName = utils.byName all; 
  byTag = utils.byTag all;
}
