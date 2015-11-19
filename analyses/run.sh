export CLASSPATH=$target:$CLASSPATH

analyse "run" $jre/bin/java $mainclass $inputargs < ${stdin:-/dev/null}
