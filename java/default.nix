# The purpose of this module is to create the java versions used in the
# benchmarks. Besides a version of jdk and jre, the java collections will also
# contain some libraries which can be used in the contex of the benchmarks.
{ pkgs }:
let
  mkJava = version: let 
    java = {
      id = "J${toString version}";
      version = version;
      jre = builtins.getAttr "jre${toString version}" pkgs;
      jdk = builtins.getAttr "jdk${toString version}" pkgs;
      libs = libs;
    };
    libs = pkgs.callPackage ./maven {} pkgs; 
    in java;
in rec {
  java5 = mkJava 5;
  java6 = mkJava 6;
  java7 = mkJava 7;
  java8 = mkJava 8;
  all = [ java5 java6 java7 java8 ];
}


