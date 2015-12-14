# The logicblox analyses are made to make it easier to
# write analyses that uses logicblox.
{python, procps, logicblox4, mkAnalysis}:
{
  mkLogicBloxAnalysis = options @ {
      jre
      , analysis
      , ...
    }:
    mkAnalysis (options // {
      inherit logicblox4 python procps;
      analysis = ./logicblox.sh;
      lbInner = options.analysis;
    });
}
