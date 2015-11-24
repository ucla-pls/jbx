{ pkgs }: 
let
  # mkBenchmark, creates benchmarks using meta data.
  mkBenchmark = meta @ {
      name
    , jarfile
    , mainclass
    , build # :: Java -> Drv
    # inputs, describes inputs which can run the program
    , inputs ? []
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
        data = if data != null then data else build_; ## if data not set set it 
      };
  pkgs_ = pkgs // { 
    callBenchmark = path: config: 
      pkgs.callPackage path { mkBenchmark = mkBenchmark; } // config;
    };

  mkJava = version: {
    id = "J${toString version}";
    version = version;
    jre = builtins.getAttr "jre${toString version}" pkgs;
    jdk = builtins.getAttr "jdk${toString version}" pkgs;
  };

  java5 = mkJava 5;
  java6 = mkJava 6;
  java7 = mkJava 7;
  java8 = mkJava 8;

in rec {
  dacapo = import ./dacapo { pkgs = pkgs_; };

  all = all8 ++ all7 ++ all6 ++ all5;
 
  generic = [
    dacapo.avrora 
    dacapo.batik
  ];

  all8 = map (f: f java8) generic;
  all7 = map (f: f java7) generic;
  all6 = map (f: f java6) generic;
  all5 = map (f: f java5) generic;
}
