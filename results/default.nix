{ benchmarks, analyses }: {
avrora = let
  avrora = benchmarks.dacapo.avrora;
  inherit (builtins) elemAt;
in {
  simple = analyses.run (elemAt avrora.runs 0) avrora;
};

}


