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
    before = '' echo "name,user,kernel,maxm" > time.csv '';
    foreach = ''tail -n +2 $run/time.csv >> time.csv''; 
  } all;

  jchord = analyses.batch (analyses.jchord.cipa-0cfa-dlog env) {
    name = "jchord-benchmarks";
  } (map (f: f java.java7) benchmarks.all);

  doop = let
    analysis = analyses.doop.context-insensitive {} env;
  in {
    avrora = analysis benchmarks.dacapo.avrora;
  };

}


