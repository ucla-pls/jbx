# The logicblox analyses are made to make it easier to
# write analyses that uses logicblox.
{python, procps, mkAnalysis}:
{
  mkLogicBloxAnalysis = options @ {
      analysis
      , logicblox
      , keepDatabase ? false
      , tools ? []
      , ...
    }:
    mkAnalysis (options // {
      inherit keepDatabase;
      tools = tools ++ [logicblox python procps];
      analysis = ./logicblox.sh;
      lbInner = options.analysis;
    });
}
