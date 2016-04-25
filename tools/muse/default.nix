# This file contains all the buildscripts for integrating
# the muse project.
{ callPackage }:
rec 
{ 
  inherit (callPackage ./randoop {}) 
    randoop-2_1_4
  ;
  randoop = randoop-2_1_4;
}
