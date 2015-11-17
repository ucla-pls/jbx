{ benchmarks, analyses, env}: {

  runAll = let
    analysis = analyses.runAll env;
  in { 
    avrora = analysis benchmarks.dacapo.avrora;
  };

  doop = let
    analysis = analyses.doop.context-insensitive {} env;
  in {
    avrora = analysis benchmarks.dacapo.avrora;
  };
  
}


