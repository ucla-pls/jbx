{ stdenv
, benchmarks
, transformers
, analyses
, java
, utils
, env
, lib
, eject
}:
let 
  inherit (utils) versionize usage onAll mkStatistics;
  all = versionize benchmarks.all java.all;
  dacapo-harness = benchmarks.byTag.dacapo-harness;
in rec {
  deadlocks = 
    onAll
      analyses.deadlock.jchord
      (versionize [java.java6] benchmarks.byTag.reflection-free)
      env;

  deadlocks-table = 
    mkStatistics {
      tools = [eject];
      name = "deadlocks-table";
      setup = ''echo "name,count" >> table.csv'';
      foreach = '' 
        v=`wc -l $result/may | cut -f1 -sd' '`
        name=''${result#*-}
        echo "$name,$v" >> table.csv
      '';
      collect = ''
        column -ts, table.csv
      '';
    } deadlocks;

  reachable-methods = 
    onAll 
      analyses.reachable-methods.petabloxExternal
      (versionize [java.java6] dacapo-harness)
      env;

  database-usage = 
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
    } reachable-methods;

  muse-backend = map (b:
    let 
      transformed = transformers.randoop b;
      benchmark = transformed.withJava java.java7;
    in stdenv.mkDerivation {
      name = "muse-backend+" + benchmark.name;
      phases = "installPhase";
      dtrace = 
        analyses.traces.daikonAll 
          benchmark env;
      dotfiles = 
        analyses.data-flow-graph.graphgen 
          (b.withJava java.java7) env;
      installPhase = ''
        mkdir $out
        cp -r $dtrace/traces $out
        cp -r $dotfiles/graphs $out
      '';
    }
  ) benchmarks.byTag.integration-test;
}
