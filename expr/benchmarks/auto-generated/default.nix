{ utils }:
let
  inherit (utils) callBenchmark;
in rec {
  A20_2_0 = callBenchmark ./A20_2_0 {};
  a_kudryashov_2_1 = callBenchmark ./a_kudryashov_2_1 {};
  abdoabdo5_0_0 = callBenchmark ./abdoabdo5_0_0 {};
  abdoabdo5_2_0 = callBenchmark ./abdoabdo5_2_0 {};
  abmargb_0_0 = callBenchmark ./abmargb_0_0 {};
  Abot3k_0_1 = callBenchmark ./Abot3k_0_1 {};
  abusi_2_1 = callBenchmark ./abusi_2_1 {};
  aditsu_0_1 = callBenchmark ./aditsu_0_1 {};
  agus.mw_0_1 = callBenchmark ./agus.mw_0_1 {};
  ALARM_2_1 = callBenchmark ./ALARM_2_1 {};
  alexey.enkov_0_1 = callBenchmark ./alexey.enkov_0_1 {};
  Biginner_0_0 = callBenchmark ./Biginner_0_0 {};
  fate_0_1 = callBenchmark ./fate_0_1 {};
  IntBfs01 = callBenchmark ./IntBfs01 {};
  IntBfs02 = callBenchmark ./IntBfs02 {};
  NabZ_0_1 = callBenchmark ./NabZ_0_1 {};
  Nayan_0_1 = callBenchmark ./Nayan_0_1 {};
  Nipunn_0_1 = callBenchmark ./Nipunn_0_1 {};
  NodeBfs01 = callBenchmark ./NodeBfs01 {};
  NodeBfs02 = callBenchmark ./NodeBfs02 {};
  Sort01 = callBenchmark ./Sort01 {};
  Sort02 = callBenchmark ./Sort02 {};
  Sort03 = callBenchmark ./Sort03 {};
  ssl01 = callBenchmark ./ssl01 {};
  ssl02 = callBenchmark ./ssl02 {};
  ssl03 = callBenchmark ./ssl03 {};
  ssl04 = callBenchmark ./ssl04 {};
  ssl05 = callBenchmark ./ssl05 {};
  ssl06 = callBenchmark ./ssl06 {};
  sunilpadda_0_0 = callBenchmark ./sunilpadda_0_0 {};
  tck_0_1 = callBenchmark ./tck_0_1 {};
  Vanja_0_1 = callBenchmark ./Vanja_0_1 {};

  all = [ A20_2_0
          a_kudryashov_2_1
          abdoabdo5_0_0
          abdoabdo5_2_0
          abmargb_0_0
          Abot3k_0_1
          abusi_2_1
          aditsu_0_1
          agus.mw_0_1
          ALARM_2_1
          alexey.enkov_0_1
          Biginner_0_0
          fate_0_1
          IntBfs01
          IntBfs02
          NabZ_0_1
          Nayan_0_1
          Nipunn_0_1
          NodeBfs01
          NodeBfs02
          Sort01
          Sort02
          Sort03
          ssl01
          ssl02
          ssl03
          ssl04
          ssl05
          ssl06
          sunilpadda_0_0
          tck_0_1
          Vanja_0_1 ];
}
