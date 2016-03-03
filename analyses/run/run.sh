source $stdenv/setup

args=`evalArgs $inputargs`

loadClasspath $build $libraries

runHook setup

analyse "run" java $mainclass $args \
    < ${stdin:-/dev/null}
