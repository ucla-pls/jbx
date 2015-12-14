# call-graph analyses 
{ shared, tools }:
{
  jchord-logicblox = shared.jchord {
    datalog = true;
    name = "call_graph";
    subanalyses = [ 
      "cipa-0cfa-dlog" 
      "cicg2dot-java" 
    ];
    postprocessing = ''
      mv sandbox/chord_output/cicg.dot .
    '';
  };
  
  jchord-bddbddb = shared.jchord {
    datalog = false;
    name = "call_graph";
    subanalyses = [ 
      "cipa-0cfa-dlog" 
      "cicg2dot-java" 
    ];
    postprocessing = ''
      mv sandbox/chord_output/cicg.dot .
    '';
  };

}
