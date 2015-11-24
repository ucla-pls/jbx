export CLASSPATH=$target:$CLASSPATH

args=""
for i in $inputargs; do
    arg=`eval "echo $i"`
    args="$args $arg"
done

analyse "run" $jre/bin/java $mainclass $args < ${stdin:-/dev/null}
