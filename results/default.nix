{ benchmarks, analyses, java, utils, env, lib, eject}:
let 
  inherit (utils) versionize usage onAll mkStatistics;
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
      analyses.reachable-methods.petabloxExternal
      (versionize [java.java6] dacapo-harness)
      env;

  database-usage = 
    database-space-use reachable-methods;

  database-space-use = 
    mkStatistics {
      tools = [eject]; 
      name = "database-useage";
      setup = ''echo "name,usage" >> usage.csv'';
      foreach = '' 
        v=`tail -n 1 $result/sandbox/lb_stats | cut -f1`
        name=''${result#*-}
        echo "$name,$v" >> usage.csv
      '';
      collect = ''
        column -ts, usage.csv
      '';
    };
}
