{ benchmarks, analyses, env}: {
  avrora = analyses.runAll env benchmarks.dacapo.avrora;
}


