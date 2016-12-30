source $stdenv/setup

if [ "$ignoreSandbox" = true ]
then
    cp -r --exclude=sandbox $result $out
else
    cp -r $result $out
fi

chmod -R u+rw $out
cd $out
export sandbox=$result/sandbox
runHook postprocess
