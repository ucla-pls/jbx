{ fetchprop, callPackage, openjdk8}:
rec {
  openjdk6 = callPackage ./openjdk6 {};

  jdk6 = callPackage ./jdk6 { fetchprop = fetchprop;};
  jdk5 = callPackage ./jdk5 { fetchprop = fetchprop;};

  jre5 = jdk5;
  jre6 = jdk6; # Not cool but works.

  inherit (callPackage ./logicblox {fetchprop = fetchprop;})
    logicblox-3_10_21
    logicblox-4_2_0
    logicblox-4_3_6_3
    logicblox-4_3_8_2
  ;
  logicblox = logicblox-4_3_8_2;

  inherit (callPackage ./doop { souffle = souffle-1_4_0; })
    doop-3_3_1
    doop-4_10_11
    doop-jdk8-4_10_11
    doop-platform
  ;

  doop = doop-4_10_11;
  doop-jdk8 = doop-jdk8-4_10_11;

  doop-platform8 = doop-platform openjdk8;

  souffle-1_4_0 = callPackage ./souffle {};

  dljc = callPackage ./do-like-javac {};

  inherit (callPackage ./jchord {})
    jchord-head
    jchord-2_0
  ;
  jchord = jchord-head;

  inherit (callPackage ./petablox {})
    petablox-0_1
    petablox-1_0
    petablox-test
    petablox-HEAD
    petablox-gt-develop
  ;
  petablox = petablox-HEAD;

  inherit (callPackage ./randoop {})
    randoop-2_1_4
    randoop-muse
  ;
  randoop = randoop-muse;

  inherit (callPackage ./graphgen {})
    graphgen
  ;

  inherit (callPackage ./daikon {})
    daikon
  ;
  
  calfuzzer = (callPackage ./calfuzzer {});

  inherit (callPackage ./wiretap {})
    wiretap
    wiretap-pointsto-src
    wiretap-pointsto
  ;

  wiretap8 = wiretap { jdk = openjdk8; };

  inherit (callPackage ./wiretap-tools {})
    wiretap-tools
  ;
  
  inherit (callPackage ./javaq {})
    javaq
    jvmhs
    jvm-binary
  ;
  
  inherit (callPackage ./tamiflex {})
    tamiflex-2_0_3
    tamiflex
  ;

  inherit (callPackage ./rvpredict { inherit fetchprop;})
    rvpredict
  ;
  
  inherit (callPackage ./soot {})
    soot-3_1_0
    soot
  ;
  
  inherit (callPackage ./wala {})
    wala-1_5_3
    wala
  ;
}
