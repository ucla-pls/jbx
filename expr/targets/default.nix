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
  withInputs = builtins.filter (b: builtins.length b.inputs > 0);
  dacapo-harness = benchmarks.byTag.dacapo-harness;
in rec {

  both = stdenv.mkDerivation {
    name = "both"; 
    phases = "installPhase";
    installPhase = ''
      mkdir $out
      cd $out
      ln -s ${deadlocks1000} deadlocks
      ln -s ${dataraces100} dataraces
      ln -s ${deadlock-stats} deadlock-stats
    '';
  }; 

  both1 = stdenv.mkDerivation {
    name = "both"; 
    phases = "installPhase";
    installPhase = ''
      mkdir $out
      cd $out
      ln -s ${deadlocks1} deadlocks
      ln -s ${dataraces1} dataraces
      ln -s ${deadlock-stats} deadlock-stats
    '';
  };

  deadlocks1 =
    deadlocks 1;
  deadlocks2 =
    deadlocks 2;
  deadlocks10 =
    deadlocks 10;
  deadlocks100 =
    deadlocks 100;
  deadlocks1000 =
    deadlocks 1000;

  deadlock-benchmarks = 
   (versionize [java.java6]
    ( with benchmarks; [
       baseline.transfer
       baseline.bensalem
       baseline.picklock
       baseline.notadeadlock
       sir.deadlock
       sir.account
       # sir.airline
       sir.diningPhilosophers
       # sir.alarmclock
       # sir.piper
       # sir.readerswriters
       # sir.replicatedworkers
       jaConTeBe.dbcp1
       jaConTeBe.dbcp2
       jaConTeBe.derby2
       jaConTeBe.log4j2
    ]));

  deadlocks =
    n:
    analyses.deadlocks.joinCycles "wiretap-cycles"
       (onAll
         (analyses.deadlocks.surveilRepeatedAll n)
         deadlock-benchmarks
         env);

  deadlock-stats = 
    analyses.stats.statsJoin 
      (onAll (analyses.stats.stats) deadlock-benchmarks env);
   
  dataraces1 =
    dataraces 1;
  dataraces2 =
    dataraces 2;
  dataraces3 =
    dataraces 3;
  dataraces5 =
    dataraces 5;
  dataraces10 =
    dataraces 10;
  dataraces100 =
    dataraces 100;
  dataraces1000 =
    dataraces 1000;

  dataraces =
    n:
    analyses.dataraces.averageAll "dataraces"
    (onAll
       (analyses.dataraces.repeatedAll n)
       (versionize [java.java6]
        ( with benchmarks; [ baseline.dependent_datarace ] ++ rvpredict.all)
       ) env);

# ++ (versionize [java.java8] benchmarks.byTag.njr)

  test = (versionize [java.java6]
		  ( with benchmarks; [
		    jaConTeBe.derby1
		    jaConTeBe.derby4
		    jaConTeBe.derby5
		  ])
	 );

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
