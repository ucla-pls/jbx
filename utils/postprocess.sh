source $stdenv/setup
cp -r $result $out
chmod -R u+rw $out
cd $out
export sandbox=sandbox
runHook postprocess
