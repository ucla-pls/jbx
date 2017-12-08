{ lib, utils, zlib, ncurses, sqlite}:
options @ { 
  subanalysis
  , doop
  , timelimit ? 3600
  , tools ? [ ]
}:
benchmark: 
utils.mkAnalysis (options // { 
  inherit timelimit;
  name = "doop-${subanalysis}";
  tools = [ doop benchmark.java.jdk zlib ncurses sqlite ] ++ tools;
  analysis = ''
    export DOOP_LOG=log DOOP_CACHE=cache DOOP_OUT=out
    doop -i $build/share/java/* -a ${subanalysis} --main $mainclass 
  '';
}) benchmark

