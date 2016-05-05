{ utils, daikon}:
let daikon_ = daikon;
in rec {
  daikon = utils.mkDynamicAnalysis {
    name = "daikon";
    tools = [ daikon_ ];
    analysis = ''
      analyse "dtrace" \
        java -cp $CLASSPATH:$classpath daikon.Chicory --output_dir=dtrace $mainclass $inputargs
    '';
    postprocess = "";
  };
  
  daikonAll = utils.onAllInputs daikon {};
}
