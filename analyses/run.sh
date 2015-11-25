
classpath="$target"

for ljar in `find $build/share/java -name *.jar`; do
    if [ "$ljar" = "$target" ]; then
        classpath="$classpath:$ljar"
    fi
done

for l in $libraries; do
    for ljar in `find $l -name *.jar`; do
        classpath="$classpath:$ljar"
    done
done

export CLASSPATH="$classpath:$CLASSPATH"

args=""
for i in $inputargs; do
    arg=`eval "echo $i"`
    args="$args $arg"
done

echo "$CLASSPATH" >> CLASSPATH

analyse "run" $jre/bin/java $mainclass $args < ${stdin:-/dev/null}
