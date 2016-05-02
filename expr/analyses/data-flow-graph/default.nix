{utils, graphgen, python, shared, pythonPackages }:
{
  graphgen = utils.mkAnalysis {
    name = "graphgen";
    tools = [ python pythonPackages.subprocess32 ];
    analysis = ''
      analyse "make-dot" python ${graphgen}/make_dots.py prog2dfg

    '';
  };
}
