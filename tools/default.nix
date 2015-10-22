{ pkgs }:
rec { 
  openjdk6 = pkgs.callPackage ./openjdk6 {};
}
