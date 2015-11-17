source $stdenv/setup

mkdir -p $out/sandbox
cd $out/sandbox

export CLASSPATH=$build/share/java/$jarfile:$CLASSPATH

$time/bin/time --output ../time \
	       $jre/bin/java $mainclass $inputargs \
	       < ${stdin:-/dev/null} \
	       1> ../stdout 2> ../stderr || true

