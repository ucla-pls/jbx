source $stdenv/setup
source $utils/tools

mkdir $out
cd $out

compose $out $results

if [ -z "$combine" ]; then
    runHook before
    for result in $results; do
	    runHook foreach
    done
    runHook after
else
    runHook combine
fi

