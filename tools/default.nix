{ pkgs }:
rec { 
  openjdk6 = pkgs.callPackage ./openjdk6 {};
  logicblox = pkgs.callPackage ./logicblox {};
  doop = pkgs.callPackage ./doop { inherit logicblox; };
}
