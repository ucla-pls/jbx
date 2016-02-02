{ tools, benchmarks, java, analyses, env, lib}:
let 
  inherit (lib.lists) concatMap filter;
  # product :: (a -> b -> c) -> [a] -> [b] -> [c]
  product = f: as: bs: concatMap (a: map (b: f a b) bs) as;
  all = filter (b: b.isWorking) (
    product (b: j: b.withJava j) benchmarks.all java.all
  );
in {
  runAll = analyses.batch (analyses.run.runAll env) {
    name = "runall-benchmarks";
  } all;

  call-graph = analyses.batch (analyses.call-graph.petablox-cicg env) {
    name = "call-graph";
    foreach = ''
      cp $result/cicg.dot ''${result#*-}.dot
    '';
  } (map (f: f.withJava java.java6) benchmarks.all);

  test = analyses.batch (
    analyses.shared.petablox {
      subanalyses = ["cipa-0cfa-dlog"];
      reflection = "external";
      petablox = tools.petablox;
      timelimit = 600;
      } env) {
    name = "test";
  } (map (f: f.withJava java.java6) 
      (lib.attrsets.attrVals 
        (map (bm: "${bm}-harness") [
          "luindex"
          "avrora"
          "xalan"
          "h2"
          "lusearch"
          "pmd"
        ]) 
        benchmarks.byName));
}


