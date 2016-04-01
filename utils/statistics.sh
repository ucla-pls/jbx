source $stdenv/setup

mkdir $out
cd $out

touch results
for result in $results; do
    echo "$result" >> results
    runHook foreach
done

runHook collect
