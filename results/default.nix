{ benchmarks, analyses }: {
avrora = let
  avrora = benchmarks.dacapo.avrora;
in {
  simple = analyses.java {
    name = "simple";
    classpath = [ "${avrora}/share/java/avrora-beta-1.7.110.jar" ];
    mainclass = "avrora.Main";
  };
};

}


