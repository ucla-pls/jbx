{ benchmarks, analyses }: {
  avrora = analyses.runAll benchmarks.dacapo.avrora;
}


