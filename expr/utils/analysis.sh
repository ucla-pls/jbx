source $stdenv/setup
source $utils


function center-text {
    >&2 echo ">>>> $1 <<<<"
}

# analyse is a function that logs important information about the
# execution of an analysis. Should be run on each major command in the
# analysis. The first argument is the identifyier of the command, it
# is used directly in the filepaths.
function analyse {
    local id=$1; shift
    center-text "JBX-STARTED $name $id"
    record "$name\$$id" "$BASE_FOLDER/$id" "${timelimit}" $@
    echo "$BASE_FOLDER/$id" >> "$BASE_FOLDER/phases"
    center-text "JBX-DONE $name $id"
}
export -f analyse

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

# Dynamic Analysis
export stdin="${stdin:-"/dev/null"}"

if [ ! -z "$inputargs" ]; then
    export args=`evalArgs $inputargs`
fi
runHook setup
# End Dynamic Analysis

runHook analysis

cd $out

kill $tpid

compose $BASE_FOLDER `cat $BASE_FOLDER/phases`

echo ${env} > env

runHook postprocess

