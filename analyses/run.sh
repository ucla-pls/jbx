source $stdenv/setup

loadClasspath $build $libraries

args=""
for i in $inputargs; do
    arg=`eval "echo $i"`
    args="$args $arg"
done

echo "$CLASSPATH" >> CLASSPATH

runHook setup

analyse "run" $jre/bin/java $mainclass $args < ${stdin:-/dev/null}
