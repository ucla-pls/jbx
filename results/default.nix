{ benchmarks, analyses, env}: {

  runAll = analyses.batch (analyses.runAll env) {
    name = "runall-benchmarks";
    combine = ''
       echo "name,user,kernel,maxm" > time.csv
          for run in $analyses; do
	     tail -n +2 $run/time.csv
	  done >> time.csv
    ''; 
    } [
      benchmarks.dacapo.avrora
    ];

  doop = let
    analysis = analyses.doop.context-insensitive {} env;
  in {
    avrora = analysis benchmarks.dacapo.avrora;
  };
  
}


