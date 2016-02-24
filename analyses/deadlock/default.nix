{shared, tools, python, postprocessors}:
rec {
  jchord = shared.jchord {
    name = "deadlock";
    jchord = tools.jchord-2_0;
    subanalyses = ["deadlock-java"];
    reflection = "dynamic";
    tools = [ python ];
    sign = "+";
    postprocessing = ''
      python2.7 ${./jchord-parse.py} sandbox/chord_output > deadlocks.txt
    '';
  };
  overview = postprocessors.overview { 
    analyses = [ jchord ];
    name = "deadlock";
    resultfile = "deadlocks.txt";
  };
}

