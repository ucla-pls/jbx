source $stdenv/setup
source $utils

if [ "$ignoreSandbox" ]
then
    pushd $result
    mkdir $out
    tar -c --exclude sandbox . | tar -x -C "$out"
    popd
else
    cp -r $result $out
fi

chmod -R u+rw $out
cd $out
export sandbox=$result/sandbox
export BASE_FOLDER="$out"

runHook postprocess

compose $BASE_FOLDER `cat $BASE_FOLDER/phases`
