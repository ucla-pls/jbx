{utils}:
{
  stats = utils.mkAnalysis {
    name = "stats";
    analysis = ''
      find $build/classes -name '*.class' -exec wc -c {} \; > $out/bytecode 
      find $build/src -name '*.java' -exec wc -l {} \; > $out/lines 
      bcsize=`awk '{c+=$1} END {print c/NR}' $out/bytecode`
      loc=`awk '{c+=$1} END {print c/NR}' $out/bytecode`
      echo "$name,$bcsize,$loc" > stats.csv
    '';
  };

  statsJoin = 
    utils.mkStatistics { 
      name = "stats";
      tools = [eject];
      foreach = ''
        cat $result/stats.csv >> stats.csv
      '';
    };
}
