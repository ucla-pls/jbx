source $stdenv/setup
source $utils

# loadTools $tools

export sandbox="$out/sandbox"
mkdir -p "$sandbox"
export BASE_FOLDER="$out"
touch $BASE_FOLDER/phases

top -b -U $UID -d 10 > $BASE_FOLDER/tops &
tpid=$!

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

kill $tpid

compose $BASE_FOLDER `cat $BASE_FOLDER/phases`
