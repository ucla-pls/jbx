{ build }:
let
  bm = name: {
    name = "monte-carlo-${name}";
    mainclass = "JGFMonteCarloBenchSize${name}";
    build = build;
    inputs = [
      {
        name ="default";
        args = [
          "5"
          "$data/data"
          "hitData"
        ];
      }
    ];
  };
in bm
