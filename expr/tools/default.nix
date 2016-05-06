{ fetchprop, callPackage}:
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

  doop = callPackage ./doop { inherit logicblox-3_10_21; };
  
  inherit (callPackage ./jchord {}) 
    jchord-head
    jchord-2_0
  ;
  jchord = jchord-head;
  
  inherit (callPackage ./petablox {}) 
    petablox-0_1
    petablox-1_0
    petablox-test
    petablox-fix
  ;
  petablox = petablox-fix;

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
} 
