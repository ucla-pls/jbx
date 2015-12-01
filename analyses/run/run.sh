source $stdenv/setup
source $utils/tools

args=`evalArgs $inputargs`
loadClasspath $build $libraries

runHook setup

analyse "run" $jre/bin/java $mainclass $args \
    < ${stdin:-/dev/null}
