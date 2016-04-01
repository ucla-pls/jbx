{ benchmarks, analyses, java, utils, env, lib}:
let 
  inherit (utils) versionize usage onAll;
  all = versionize benchmarks.all java.all;
  dacapo-harness =
      (lib.attrsets.attrVals 
        (map (bm: "${bm}-harness") [
          "avrora"
          "batik"
          "eclipse"
          "fop"
          "h2"
          "jython"
          "luindex"
          "lusearch"
          "pmd"
          "sunflow"
          "tomcat"
          "tradebeans"
          "tradesoap"
          "xalan"
          ])
        benchmarks.byName);
in rec {
  reachable-methods = 
    onAll 
      analyses.reachable-methods.emmaAll
      (versionize [java.java6] dacapo-harness)
      env;

  reachable-methods-usage = 
    utils.usage "reacable-method-usage" reachable-methods;
}


