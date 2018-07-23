{utils}:
{
  stats = utils.mkAnalysis {
    name = "stats";
    tools = [];
    analysis = ''
      find $build/classes -name '*.class' -exec wc -c {} \; > $out/bytecode 
      if [ -e $build/lib ]
      then
        find $build/lib -name '*.class' -exec wc -c {} \; >> $out/bytecode 
      fi
      find $build/src -name '*.java' -exec wc -l {} \; > $out/lines 
      # javaq --cp $classpath -f csv >> $out/classes.csv
      # javaq --cp $classpath -f jsons-full | jq -s '[.[].methods[].code.byte_code | length ] | add'  >> $out/instructions
      bcsize=`awk '{c+=$1} END {print c}' $out/bytecode`
      loc=`awk '{c+=$1} END {print c}' $out/lines`
      classes=`awk 'END {print NR}' $out/bytecode`
      # instructions=`cat $out/instructions`
      echo "$name,$loc,$classes,$bcsize" > $out/stats.csv
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
