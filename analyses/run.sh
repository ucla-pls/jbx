export CLASSPATH=$build/share/java/$jarfile:$CLASSPATH

analyse "run" $jre/bin/java $mainclass $inputargs < ${stdin:-/dev/null}
