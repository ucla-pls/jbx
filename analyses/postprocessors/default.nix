{ python, lib, batch, eject}:
let inherit (lib.lists) concatMap filter;
in rec {

  # product :: (a -> b -> c) -> [a] -> [b] -> [c]
  product = f: as: bs: concatMap (a: map (b: f a b) bs) as;

  # produces a list of benchmarks
  versionize = javas: benchmarks: filter (b: b.isWorking) (
    product (b: j: b.withJava j) benchmarks javas
  );

  # The compatablitiy table computes a table with a benchmarks in rows and java
  # versions as coloums. 
  compatablity-table = analysis: versions:
    batch analysis { 
      name = "compat-table";
      foreach = ''
        cat $result/result.csv >> data.csv
      '';
      buildInputs = [ python eject ];
      after = ''
      source $stdenv/setup
      python2.7 ${./transpose.py} <data.csv >table.csv
      column -s',' -t table.csv
      '';
    } versions;

}


