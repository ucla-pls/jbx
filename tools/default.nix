{ pkgs, fetchprop }:
rec { 
  openjdk6 = pkgs.callPackage ./openjdk6 {};
  jre6 = pkgs.callPackage ./jre6 { fetchprop = fetchprop;};
  inherit (pkgs.callPackage ./logicblox {fetchprop = fetchprop;}) logicblox3 logicblox4;
  logicblox = logicblox4;
  doop = pkgs.callPackage ./doop { inherit logicblox3; };
  jchord = pkgs.callPackage ./jchord {};
}
