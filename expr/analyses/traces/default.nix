{ utils, daikon}:
let daikon_ = daikon;
in {
  daikon = utils.mkDynamicAnalysis {
    name = "daikon";
    tools = [ daikon ];
    analysis = ''
      analyse "dtrace" \
        java -cp $CLASSPATH:$classpath daikon.Chicory --output_dir=dtrace $mainclass $inputargs
    '';
  };
  
  daikonAll = utils.onAllInputs daikon {};
}
