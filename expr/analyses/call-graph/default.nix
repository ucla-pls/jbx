# call-graph analyses 
{ shared, tools }:
{
  jchord-cicg-logicblox = shared.jchord {
    datalog = true;
    name = "cicg";
    subanalyses = [ 
      "cicg2dot-java" 
    ];
    postprocessing = ''
      mv sandbox/chord_output/cicg.dot .
    '';
  };
  
  petablox-cicg = shared.petablox {
    logicblox = null; # tools.logicblox-4_2_0;
    petablox = tools.petablox;
    name = "cicg";
    reflection = "external";
    subanalyses = [ 
      "cicg2dot-java" 
    ];
    postprocessing = ''
     mv sandbox/petablox_output/cicg.dot .
    '';
  };
  
  jchord-cicg-bddbddb = shared.jchord {
    datalog = false;
    name = "cicg";
    subanalyses = [ 
      "cicg2dot-java" 
    ];
    postprocessing = ''
      mv sandbox/chord_output/cicg.dot .
    '';
  };

}
