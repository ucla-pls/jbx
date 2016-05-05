{ fetchgit, utils, ant, cpio }:
let
  bm = { name, main, builddir, srcdir, destdir }: utils.mkBenchmarkTemplate {
    tags = [ "mini_corpus" ];
    name = name;
    mainclass = main;
    build = java: {
      src = fetchgit {
        url = "https://github.com/aas-integration/mini_corpus.git";
        branchName = "master";
        rev = "14ec94d8d9808905a21fd839e5bdd2cb8248a11c";
        md5 = "3b09245a1e28e430798fe4335ec5c5ba";
      };
      phases = [ "unpackPhase" "buildPhase" "installPhase" ];
      buildInputs = [ ant java.jdk cpio ];
      buildPhase = ''
        cd ${builddir}
        ant
        cd ${destdir}
        jar vcf ${name}.jar .
      '';
      installPhase = ''
        mkdir -p $out/share/java/
        mv ${name}.jar $_
        cd ../${srcdir}
        mkdir -p $out/src/
        find . -name '*.java' | cpio -pdm $out/src
      '';
    };
  };
in rec {
  Sort02 = bm {
    name = "Sort02";
    main = "Sort02";
    builddir = "sorting/00_sort/Sort02";
    destdir = "classes";
    srcdir = "src";
  };

  Sort01 = bm {
    name = "Sort01";
    main = "Sort01";
    builddir = "sorting/00_sort/Sort01";
    destdir = "classes";
    srcdir = "src";
  };

  Sort03 = bm {
    name = "Sort03";
    main = "Sort02";
    builddir = "sorting/00_sort/Sort03";
    destdir = "classes";
    srcdir = "src";
  };

  sunilpadda_0_0 = bm {
    name = "sunilpadda_0_0";
    main = "TextMessaging";
    builddir = "benchmarks/08_text_messaging_outrage/sunilpadda_0_0";
    destdir = "classes";
    srcdir = "src";
  };

  Biginner_0_0 = bm {
    name = "Biginner_0_0";
    main = "try1";
    builddir = "benchmarks/08_text_messaging_outrage/Biginner_0_0";
    destdir = "classes";
    srcdir = "src";
  };

  tck_0_1 = bm {
    name = "tck_0_1";
    main = "A";
    builddir = "benchmarks/08_text_messaging_outrage/tck_0_1";
    destdir = "classes";
    srcdir = "src";
  };

  fate_0_1 = bm {
    name = "fate_0_1";
    main = "problem1";
    builddir = "benchmarks/08_text_messaging_outrage/fate_0_1";
    destdir = "classes";
    srcdir = "src";
  };

  abmargb_0_0 = bm {
    name = "abmargb_0_0";
    main = "DecisionTree";
    builddir = "benchmarks/09_decision_tree/abmargb_0_0";
    destdir = "classes";
    srcdir = "src";
  };

  agus.mw_0_1 = bm {
    name = "agus.mw_0_1";
    main = "AMain";
    builddir = "benchmarks/09_decision_tree/agus.mw_0_1";
    destdir = "classes";
    srcdir = "src";
  };

  aditsu_0_1 = bm {
    name = "aditsu_0_1";
    main = "Decision";
    builddir = "benchmarks/09_decision_tree/aditsu_0_1";
    destdir = "classes";
    srcdir = "src";
  };

  Abot3k_0_1 = bm {
    name = "Abot3k_0_1";
    main = "DecisionTree";
    builddir = "benchmarks/09_decision_tree/Abot3k_0_1";
    destdir = "classes";
    srcdir = "src";
  };

  abdoabdo5_0_0 = bm {
    name = "abdoabdo5_0_0";
    main = "probA";
    builddir = "benchmarks/09_decision_tree/abdoabdo5_0_0";
    destdir = "classes";
    srcdir = "src";
  };

  alexey.enkov_0_1 = bm {
    name = "alexey.enkov_0_1";
    main = "Solution";
    builddir = "benchmarks/09_decision_tree/alexey.enkov_0_1";
    destdir = "classes";
    srcdir = "src";
  };

  abdoabdo5_2_0 = bm {
    name = "abdoabdo5_2_0";
    main = "Problem3";
    builddir = "benchmarks/10_your_rank_is_pure/abdoabdo5_2_0";
    destdir = "classes";
    srcdir = "src";
  };

  abusi_2_1 = bm {
    name = "abusi_2_1";
    main = "C";
    builddir = "benchmarks/10_your_rank_is_pure/abusi_2_1";
    destdir = "classes";
    srcdir = "src";
  };

  a_kudryashov_2_1 = bm {
    name = "a_kudryashov_2_1";
    main = "Solution";
    builddir = "benchmarks/10_your_rank_is_pure/a_kudryashov_2_1";
    destdir = "classes";
    srcdir = "src";
  };

  ALARM_2_1 = bm {
    name = "ALARM_2_1";
    main = "Main";
    builddir = "benchmarks/10_your_rank_is_pure/ALARM_2_1";
    destdir = "classes";
    srcdir = "src";
  };

  A20_2_0 = bm {
    name = "A20_2_0";
    main = "CodeJam";
    builddir = "benchmarks/10_your_rank_is_pure/A20_2_0";
    destdir = "classes";
    srcdir = "src";
  };

  Nayan_0_1 = bm {
    name = "Nayan_0_1";
    main = "RPI";
    builddir = "benchmarks/11_rpi/Nayan_0_1";
    destdir = "classes";
    srcdir = "src";
  };

  Nipunn_0_1 = bm {
    name = "Nipunn_0_1";
    main = "RPI";
    builddir = "benchmarks/11_rpi/Nipunn_0_1";
    destdir = "classes";
    srcdir = "src";
  };

  Vanja_0_1 = bm {
    name = "Vanja_0_1";
    main = "A";
    builddir = "benchmarks/11_rpi/Vanja_0_1";
    destdir = "classes";
    srcdir = "src";
  };

  NabZ_0_1 = bm {
    name = "NabZ_0_1";
    main = "CodeJam";
    builddir = "benchmarks/11_rpi/NabZ_0_1";
    destdir = "classes";
    srcdir = "src";
  };

  IntBfs01 = bm {
    name = "IntBfs01";
    main = "IntBfs01";
    builddir = "benchmarks/00_bfs/IntBfs01";
    destdir = "classes";
    srcdir = "src";
  };

  NodeBfs02 = bm {
    name = "NodeBfs02";
    main = "NodeBfs02";
    builddir = "benchmarks/00_bfs/NodeBfs02";
    destdir = "classes";
    srcdir = "src";
  };

  NodeBfs01 = bm {
    name = "NodeBfs01";
    main = "NodeBfs01";
    builddir = "benchmarks/00_bfs/NodeBfs01";
    destdir = "classes";
    srcdir = "src";
  };

  IntBfs02 = bm {
    name = "IntBfs02";
    main = "IntBfs02";
    builddir = "benchmarks/00_bfs/IntBfs02";
    destdir = "classes";
    srcdir = "src";
  };

  ssl05 = bm {
    name = "ssl05";
    main = "Ssl05";
    builddir = "benchmarks/01_ssl/ssl05";
    destdir = "classes";
    srcdir = "src";
  };

  ssl02 = bm {
    name = "ssl02";
    main = "Ssl02";
    builddir = "benchmarks/01_ssl/ssl02";
    destdir = "classes";
    srcdir = "src";
  };

  ssl01 = bm {
    name = "ssl01";
    main = "Ssl01";
    builddir = "benchmarks/01_ssl/ssl01";
    destdir = "classes";
    srcdir = "src";
  };

  ssl03 = bm {
    name = "ssl03";
    main = "Ssl03";
    builddir = "benchmarks/01_ssl/ssl03";
    destdir = "classes";
    srcdir = "src";
  };

  ssl06 = bm {
    name = "ssl06";
    main = "Ssl06";
    builddir = "benchmarks/01_ssl/ssl06";
    destdir = "classes";
    srcdir = "src";
  };

  ssl04 = bm {
    name = "ssl04";
    main = "Ssl04";
    builddir = "benchmarks/01_ssl/ssl04";
    destdir = "classes";
    srcdir = "src";
  };


  all = [
    Sort02
    Sort01
    Sort03
    sunilpadda_0_0
    Biginner_0_0
    tck_0_1
    fate_0_1
    abmargb_0_0
    agus.mw_0_1
    aditsu_0_1
    Abot3k_0_1
    abdoabdo5_0_0
    alexey.enkov_0_1
    abdoabdo5_2_0
    abusi_2_1
    a_kudryashov_2_1
    ALARM_2_1
    A20_2_0
    Nayan_0_1
    Nipunn_0_1
    Vanja_0_1
    NabZ_0_1
    IntBfs01
    NodeBfs02
    NodeBfs01
    IntBfs02
    ssl05
    ssl02
    ssl01
    ssl03
    ssl06
    ssl04
  ];
}
