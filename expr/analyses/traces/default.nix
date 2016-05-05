{ utils, daikon}:
let daikon_ = daikon;
in rec {
  daikon = utils.mkDynamicAnalysis {
    name = "daikon";
    tools = [ daikon_ ];
    analysis = ''
      echo "$CLASSPATH   ---  $classpath"
      analyse "dtrace" \
        java -cp $CLASSPATH:$classpath daikon.Chicory --output_dir=dtrace $mainclass $inputargs
    '';
    postprocess = '' 
      mkdir traces
      for name in $(find sandbox/dtrace -type f)
      do
        bname=$(basename $name)
        echo $bname
        cp $name "traces/$inputname.$bname"
      done
    '';
  };
  
  daikonAll = utils.onAllInputs daikon {
    collect = ''
      mkdir -p $out/traces
      for result in $results
      do
        cp $result/traces/* $out/traces
      done
    '';
  };
}
