{utils}:
{
  stats = utils.mkAnalysis {
    name = "stats";
    analysis = ''
      find $build/classes -name '*.class' -exec wc -c {} \; > $out/bytecode 
      if [ -e $build/lib ]
      then
        find $build/lib -name '*.class' -exec wc -c {} \; >> $out/bytecode 
      fi
      find $build/src -name '*.java' -exec wc -l {} \; > $out/lines 
      bcsize=`awk '{c+=$1} END {print c}' $out/bytecode`
      loc=`awk '{c+=$1} END {print c}' $out/lines`
      classes=`awk 'END {print NR}' $out/bytecode`
      echo "$name,$loc,$classes,$bcsize" > $out/stats.csv
      cat $out/lines
    '';
  };

  statsJoin = 
    utils.mkStatistics { 
      name = "stats";
      tools = [];
      foreach = ''
        cat $result/stats.csv >> stats.csv
      '';
    };
}
