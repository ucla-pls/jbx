{ pkgs, tools, mkAnalysis, jarOf}:
rec { 
  base =
   env:
   options @ {
      subanalysis
   }:
   benchmark: 
   mkAnalysis rec {
     name = "jchord-${subanalysis}-${benchmark.name}";
     analysis = ./jchord.sh;
     inherit env;

     jchord = tools.jchord;
     jre = pkgs.jre7;
     inherit (benchmark) mainclass;
     inherit (tools) logicblox4;

     settings = ''
       chord.main.class=${benchmark.mainclass}
       chord.class.path=${jarOf benchmark}
       chord.run.analyses=${subanalysis},logicblox-export
       chord.datalog.engine=logicblox4
       chord.err.file=/dev/stderr
       chord.out.file=/dev/stdout
     '';
  };

  cipa-0cfa-dlog = env: base env { subanalysis = "cipa-0cfa-dlog"; };
}
