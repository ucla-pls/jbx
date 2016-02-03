{ tools, benchmarks, java, analyses, env, lib}:
let 
  inherit (analyses.postprocessors) versionize compatablity-table;
  all = versionize benchmarks.all java.all;
  dacapo-harness =
      (lib.attrsets.attrVals 
        (map (bm: "${bm}-harness") [
          "luindex"
          "avrora"
          "xalan"
          "h2"
          "lusearch"
          # "pmd"
          "batik"
          "tomcat"
          "sunflow"
          ])
        benchmarks.byName);
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

  compat-table = 
    compatablity-table
      (analyses.run.runAll env)
      (versionize 
        [ java.java5 java.java6 java.java7 java.java8 ]
        [ benchmarks.byName.luindex benchmarks.byName.avrora benchmarks.byName.lusearch ])
  ;

  test = analyses.batch (
    analyses.shared.petablox {
      subanalyses = ["cipa-0cfa-dlog"];
      reflection = "external";
      petablox = tools.petablox;
      timelimit = 600;
      } env) {
    name = "test";
  } (map (f: f.withJava java.java6) dacapo-harness);
}


