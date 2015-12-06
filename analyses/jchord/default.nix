{ pkgs, tools, mkLogicBloxAnalysis, jarOf}:
rec { 
  base =
    env:
    options @ {
      subanalysis
      , datalog ? true
    }:
    benchmark: 
    let 
      options = rec {
        name = "jchord-${if datalog then "dlog" else "bddbddb"}-${subanalysis}-${benchmark.name}";
        analysis = ./jchord.sh;
        inherit env;

        jchord = tools.jchord;
        jre = benchmark.java.jre;
        inherit (benchmark) mainclass build libraries;

        settings = ''
chord.main.class=${benchmark.mainclass}
chord.run.analyses=${subanalysis}
${if datalog then "chord.datalog.engine=logicblox4" else ""}
chord.err.file=/dev/stderr
chord.out.file=/dev/stdout
'';
      };
    in 
    if datalog then 
      mkLogicBloxAnalysis options
    else
      mkAnalysis options


  cipa-0cfa-dlog = env: base env { subanalysis = "cipa-0cfa-dlog"; };
  deadlock = env: base env { subanalysis = "deadlock-java"; };
}
