{ pkgs, fetchprop }:
rec { 
  openjdk6 = pkgs.callPackage ./openjdk6 {};
  
  jdk6 = pkgs.callPackage ./jdk6 { fetchprop = fetchprop;};
  jdk5 = pkgs.callPackage ./jdk5 { fetchprop = fetchprop;};
  
  jre5 = jdk5;
  jre6 = jdk6; # Not cool but works.

  inherit (pkgs.callPackage ./logicblox {fetchprop = fetchprop;}) logicblox3 logicblox4;
  logicblox = logicblox4;
  doop = pkgs.callPackage ./doop { inherit logicblox3; };
  jchord = pkgs.callPackage ./jchord {};
  inherit (pkgs.callPackage ./petablox {}) petablox_0_1;
  petablox = petablox_0_1;
}
