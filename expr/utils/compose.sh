source $stdenv/setup
source $utils

mkdir $out
cd $out

compose $out $results

mkdir results
for result in $results; do
    ln -s "$result" results/${result#*-} 
done

for f in $results; do
    if [ -e "$f/upper" ]; then
        if [ ! -e upper ]; then
            cp "$f/upper" upper
        else
            comm -12 "$f/upper" upper > tmp
            mv -f tmp upper
        fi
    fi
    if [ -e "$f/lower" ]; then
        if [ ! -e lower ]; then
            cp "$f/lower" lower
        else
            sort -m "$f/lower" lower | uniq > tmp
            mv -f tmp lower
        fi
    fi
done

for f in $results; do
    if [ -e "$f/error" ]; then
        cat "$f/error" >> error;
    fi
done

runHook collect
