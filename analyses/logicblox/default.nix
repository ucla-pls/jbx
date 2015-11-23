# The logicblox analyses are made to make it easier to
# write analyses that uses logicblox.
{}:
{
  mkLogicBloxAnalysis = options:
    mkAnalysis (options // {
      inherit (tools) logicblox4;
      inherit (pkgs) python procps;
      analysis = ./logicblox.sh
      lbInner = options.analysis
    })
}
