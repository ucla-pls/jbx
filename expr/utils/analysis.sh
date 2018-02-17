source $stdenv/setup
source $utils

# loadTools $tools

export sandbox="$out/sandbox"
mkdir -p "$sandbox"
export BASE_FOLDER="$out"
touch $BASE_FOLDER/phases

cd $out/sandbox

export classpath=`toClasspath $build $libraries`
export srcpath="$build/src"
echo ${env} > env

# Dynamic Analysis
export stdin="${stdin:-"/dev/null"}"

if [ ! -z "$inputargs" ]; then
    export args=`evalArgs $inputargs`
fi
runHook setup
# End Dynamic Analysis

runHook analysis

cd $out

runHook postprocess

compose $BASE_FOLDER `cat $BASE_FOLDER/phases`
