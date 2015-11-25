{ pkgs, java}: 
let
  # mkBenchmark, creates benchmarks using meta data.
  mkBenchmark = meta @ {
      name
    , jarfile
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
    java: # Given a version of java
      assert filter java.version;
      let 
        build_ = pkgs.stdenv.mkDerivation (build java // { 
          name = name; 
        });
      in meta // {
        name = name + java.id;
        build = build_;
        java = java;
        inputs = inputs;
        data = if data != null then data else build_; ## if data not set set it 
        libraries = libraries java;
      };
  callBenchmark = path: config: 
    mkBenchmark (pkgs.callPackage path config);
in rec {
  dacapo = import ./dacapo { inherit pkgs callBenchmark; };

  # all = all8 ++ all7 ++ all6 ++ all5;

  all = map (f: f java) generic;
 
  generic = [
    dacapo.avrora 
    dacapo.sunflow
  ];

  # all8 = map (f: f java8) generic;
  # all7 = map (f: f java7) generic;
  # all6 = map (f: f java6) generic;
  # all5 = map (f: f java5) generic;
}
