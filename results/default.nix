{ benchmarks, analyses }: {
avrora = let
  avrora = benchmarks.dacapo.avrora;
in {
  simple = analyses.run
     { name = "simple"; args = []; }
     avrora;
};

}


