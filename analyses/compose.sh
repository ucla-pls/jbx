source $stdenv/setup

mkdir $out
cd $out

if [ -z "$combine" ]; then
    runHook before
    for run in $analyses; do
	runHook foreach
    done
    runHook after
else
    runHook combine
fi

