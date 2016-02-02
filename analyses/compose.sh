source $stdenv/setup
source $utils/tools

mkdir $out
cd $out


if [ -z "$combine" ]; then
    runHook before
    for result in $results; do
	    runHook foreach
    done
    runHook after
else
    runHook combine
fi

compose $out $results
