{ pkgs, fetchprop }:
rec { 
  openjdk6 = pkgs.callPackage ./openjdk6 {};
  
  jdk6 = pkgs.callPackage ./jdk6 { fetchprop = fetchprop;};
  jdk5 = pkgs.callPackage ./jdk5 { fetchprop = fetchprop;};
  
  jre5 = jdk5;
  jre6 = jdk6; # Not cool but works.

  inherit (pkgs.callPackage ./logicblox {fetchprop = fetchprop;}) 
    logicblox-3_10_21 
    logicblox-4_2_0
    logicblox-4_3_6_3
  ;
  logicblox = logicblox-4_3_6_3;

  doop = pkgs.callPackage ./doop { inherit logicblox-3_10_21; };
  
  inherit (pkgs.callPackage ./jchord {}) 
    jchord-head
    jchord-2_0
  ;
  jchord = jchord-head;
  
  inherit (pkgs.callPackage ./petablox {}) 
    petablox-0_1
    petablox-1_0
    petablox-test
  ;
  petablox = petablox-test;
}
