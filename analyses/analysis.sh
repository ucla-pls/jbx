source $stdenv/setup
source $utils/tools

# analyse is a function that logs important information about the
# execution of an analysis. Should be run on each major command in the
# analysis. The first argument is the identifyier of the command, it
# is used directly in the filepaths.
function analyse {
    local id=$1; shift
    record "$name-$id" "$BASE_FOLDER/$id" "${timelimit}" $@
    echo "$BASE_FOLDER/$id" >> "$BASE_FOLDER/phases"
}
export -f analyse

# loadTools $tools

mkdir -p $out/sandbox
export BASE_FOLDER="$out"
touch $BASE_FOLDER/phases

top -b -U $UID -d 10 > $out/tops &
tpid=$!

cd $out/sandbox

runHook analysis

cd $out

kill $tpid

compose $BASE_FOLDER `cat $BASE_FOLDER/phases`

echo ${env} > env

runHook postprocessing

