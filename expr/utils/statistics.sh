source $stdenv/setup

mkdir $out
cd $out

runHook setup

runHook before

mkdir results
for result in $results; do
    ln -s "$result" results/${result#*-} 
    runHook foreach
done

runHook collect
