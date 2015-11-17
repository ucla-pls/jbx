source $stdenv/setup

mkdir $out

echo "name,user,kernel,maxm" > $out/time.csv
for run in $runs; do
    name=${run#*"-"}
    echo -n "$name,"
    cat $run/time
done >> $out/time.csv

