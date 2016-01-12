{ pkgs, java}: 
let
  # mkBenchmark, creates benchmarks using meta data.
  mkBenchmark = meta @ {
      name
    , mainclass
    , build # :: Java -> Drv
    # inputs, describes inputs which can run the program
    , inputs ? []
    # runtime libraries 
    , libraries ? java: []
    # tags, can be added to help search
    , tags ? []
    # filter enables us to filter on java versions
    , filter ? jv: true
    , data ? null # a data repository, for tests
    , ...
    }:
    {
      name = name;
      filter = filter;
      tags = tags;
      withJava = java: # Given a version of java
        let 
          build_ = pkgs.stdenv.mkDerivation ({ 
            name = name + java.id; 
          } // build java);
        in meta // {
          name = name + java.id;
          build = build_;
          java = java;
          inputs = inputs;
          isWorking = filter java;
          data = if data != null then data else build_; ## if data not set set it 
          libraries = libraries java;
        };
    };
  callBenchmark = path: config: 
    mkBenchmark (pkgs.callPackage path config);
  dacapo = import ./dacapo { inherit pkgs callBenchmark; };
  baseline = pkgs.callPackage ./baseline { inherit mkBenchmark; };
  independent = import ./dacapo { inherit pkgs callBenchmark; };
in rec {
  all = [
    dacapo.avrora
    dacapo.h2
    dacapo.sunflow
    dacapo.pmd
    dacapo.batik
    baseline.transfer
    dacapo.luindex
  ];
  small = [
    baseline.transfer
  ];
  byName = builtins.listToAttrs (map (b: { name = b.name; value = b; }) all);
}
