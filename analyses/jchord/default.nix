{ pkgs, tools, mkLogicBloxAnalysis, jarOf}:
rec { 
  base =
    env:
    options @ {
      subanalysis
    }:
    benchmark: 
    mkLogicBloxAnalysis rec {
      name = "jchord-${subanalysis}-${benchmark.name}";
      analysis = ./jchord.sh;
      inherit env;

      jchord = tools.jchord;
      jre = benchmark.java.jre;
      inherit (benchmark) mainclass build libraries;

      settings = ''chord.main.class=${benchmark.mainclass}
        chord.run.analyses=${subanalysis}
        chord.datalog.engine=logicblox4
        chord.err.file=/dev/stderr
        chord.out.file=/dev/stdout'';
    };

  cipa-0cfa-dlog = env: base env { subanalysis = "cipa-0cfa-dlog"; };
  deadlock = env: base env { subanalysis = "deadlock-java"; };
}
