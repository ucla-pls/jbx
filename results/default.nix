{ benchmarks, java, analyses, env, lib}:
let 
  inherit (lib.lists) concatMap filter;
  # product :: (a -> b -> c) -> [a] -> [b] -> [c]
  product = f: as: bs: concatMap (a: map (b: f a b) bs) as;
  all = filter (b: b.isWorking) (
    product (b: j: b j) benchmarks.all java.all
  );
in {
  runAll = analyses.batch (analyses.runAll env) {
    name = "runall-benchmarks";
  } all;

  call-graph = analyses.batch (analyses.call-graph.jchord-bddbddb env) {
    name = "call-graph";
  } (map (f: f java.java7) benchmarks.small);

}


