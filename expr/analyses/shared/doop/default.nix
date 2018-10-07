{ lib, utils, zlib, ncurses, sqlite, souffle-1_4_0 }:
options @ { 
  subanalysis
  , doop
  , timelimit ? 3600
  , tools ? [ ]
  , ...
}:
benchmark: 
let name = "doop-${subanalysis}";
in
utils.mkAnalysis (options // { 
  inherit timelimit name;
  tools = [ doop benchmark.java.jdk zlib ncurses sqlite souffle-1_4_0 ] ++ tools;
  analysis = ''
    export DOOP_LOG=log DOOP_CACHE=cache DOOP_OUT="$(pwd)/out"
    mkdir -p out
    analyse "${name}" doop --platform java_7 -i $classpath -a ${subanalysis} -id 0 --main $mainclass 
  '';
}) benchmark

