{shared, tools}:
{
  jchord = shared.jchord {
    name = "deadlock";
    jchord = tools.jchord-2_0;
    subanalyses = ["deadlock-java"];
  };
}

