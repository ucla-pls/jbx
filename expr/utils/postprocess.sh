source $stdenv/setup
source $utils

if [ "$ignoreSandbox" = true ]
then
    cp -r --exclude=sandbox $result $out
else
    cp -r $result $out
fi

chmod -R u+rw $out
cd $out
export sandbox=$result/sandbox
export BASE_FOLDER="$out"

runHook postprocess

compose $BASE_FOLDER `cat $BASE_FOLDER/phases`
