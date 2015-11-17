{ benchmarks, analyses, env}: {

  runAll = let
    analysis = analyses.runAll env;
  in { 
    avrora = analysis benchmarks.dacapo.avrora;
  };

  doop = let
    analysis = analyses.doop.contex-insensitive {} env;
  in {
    avrora = analyses benchmarks.dacaop.avrora;
  };
  
}


