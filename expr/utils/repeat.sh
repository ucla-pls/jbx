source $stdenv/setup
source $utils

# loadTools $tools
for i in $(seq 1 $repeat_times)
do
    export BASE_FOLDER="$out/repeat-$(printf %04d $i)"

    export sandbox="$BASE_FOLDER/sandbox"
    mkdir -p "$sandbox"
    echo "$BASE_FOLDER" >> $out/repeats.txt

    touch "$BASE_FOLDER/phases"

    top -b -U $UID -d 10 > $BASE_FOLDER/tops &
    tpid=$!

    cd "$sandbox"

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

    cd "$BASE_FOLDER"

    runHook postprocess

    kill $tpid

    compose "$BASE_FOLDER" `cat $BASE_FOLDER/phases`
done

compose "$out" `cat $out/repeats.txt`
