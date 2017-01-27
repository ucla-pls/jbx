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
  with_inputs = builtins.filter (b: builtins.length b.inputs > 0);
  dacapo-harness = benchmarks.byTag.dacapo-harness;
in rec {
  deadlocks =
    onAll
      analyses.deadlock.petablox
      (versionize [java.java6] benchmarks.byTag.reflection-free)
      env;

  wiretap-deadlocks =
    onAll
      analyses.deadlock.surveilAll
      (versionize [java.java6] (with_inputs benchmarks.byTag.deadlock ))
      env;

  wiretap-deadlocks-table =
    mkStatistics {
      tools = [eject];
      name = "deadlocks-table";
      setup = ''echo "name,count" >> table.csv'';
      foreach = ''
        if [ -e "$result/lower" ]
        then
          v=`wc -l $result/lower | cut -f1 -sd' '`
        else
          v="Err"
        fi
        name=''${result#*-}
        echo "$name,$v" >> table.csv
      '';
      collect = ''
        column -ts, table.csv
      '';
    } wiretap-deadlocks;

  deadlocks-table =
    mkStatistics {
      tools = [eject];
      name = "deadlocks-table";
      setup = ''echo "name,count" >> table.csv'';
      foreach = ''
        if [ -e "$result/upper" ]
        then
          v=`wc -l $result/upper | cut -f1 -sd' '`
        else
          v="Err"
        fi
        name=''${result#*-}
        echo "$name,$v" >> table.csv
      '';
      collect = ''
        column -ts, table.csv
      '';
    } deadlocks;

  reachable-methods =
    onAll
      analyses.reachable-methods.overview
      (versionize [java.java6] dacapo-harness)
      env;

  reachable-methods-table =
    mkStatistics {
      name = "reachable-methods-table";
      foreach = ''
        cp -r $result ''${result##*+}
      '';
    } reachable-methods;

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
