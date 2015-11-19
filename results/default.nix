{ benchmarks, analyses, env}: let
  working = [
      benchmarks.dacapo.avrora
  ];
in {

   runAll = analyses.batch (analyses.runAll env) {
      name = "runall-benchmarks";
      before = '' echo "name,user,kernel,maxm" > time.csv '';
      foreach = ''tail -n +2 $run/time.csv >> time.csv''; 
    } working;

  jchord = analyses.batch (analyses.jchord.cipa-0cfa-dlog env) {
    name = "jchord-benchmarks";
  } working;

  doop = let
    analysis = analyses.doop.context-insensitive {} env;
  in {
    avrora = analysis benchmarks.dacapo.avrora;
  };
  
}


