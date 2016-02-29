{ callPackage, utils }:
rec {
  dacapo = callPackage ./dacapo {};
  baseline = callPackage ./baseline {};
  independent = callPackage ./dacapo {};
 
  # All benchmarks should be registered here
  all =  baseline.all 
      ++ dacapo.all; 

  byName = utils.byName all; 
  byTag = utils.byTag all;
}
