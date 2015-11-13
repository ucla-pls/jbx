{ pkgs }:
rec { 
  openjdk6 = pkgs.callPackage ./openjdk6 {};
  inherit (pkgs.callPackage ./logicblox {}) logicblox3 logicblox4;
  logicblox = logicblox4;
  doop = pkgs.callPackage ./doop { inherit logicblox3; };
}
