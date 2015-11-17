{ benchmarks, analyses }: let
  env = {
    name = "Christian's Laptop";
    processor = "2.9 GHz Intel Core i5";
    cores = 2;
    memory = "1867 MHz DDR3";
    memorysize = 8192;
  };
in {
  avrora = analyses.runAll env benchmarks.dacapo.avrora;
}


