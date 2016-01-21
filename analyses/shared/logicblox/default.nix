# The logicblox analyses are made to make it easier to
# write analyses that uses logicblox.
{python, procps, mkAnalysis}:
{
  mkLogicBloxAnalysis = java: logicblox: options @ {
      analysis
      , keepDatabase ? false
      , tools ? []
      , ...
    }:
    mkAnalysis (options // {
      tools = tools ++ [logicblox python procps java.jre];
      logicblox = logicblox;
      analysis = ./logicblox.sh;
      lbInner = options.analysis;
    });
}
