source $stdenv/setup

mkdir $out
cd $out

runHook setup

none_races=`awk '!/<clinit>/' $dirk/none.dataraces.txt | wc -l  | cut -f1 -d' '`
dirk_races=`awk '!/<clinit>/' $dirk/dirk.dataraces.txt | wc -l | cut -f1 -d' '`
rvp_races=`wc -l $rvp/lower | cut -f1 -d' '`
cat "$rvp/lower" "$dirk/dirk.dataraces.txt" | sort > lower
dirk_length=`sed 's/[^0-9,]//g;s/,/\n/g' "$dirk/history.count.txt" | awk '{x+=$1} END { print x}'`
set +e
rvp_length=`grep "Trace Size: " $rvp/rv-predict/stdout | cut -d' ' -f3`
set -e

if [ -z "$rvp_length" ]; 
then
	rvp_length=0
fi

cat $dirk/times.csv $rvp/times.csv > times.csv

run_time=`grep run times.csv | cut -f2 -d','`
rv_record_time=`grep rv-record times.csv | cut -f2 -d','`
rv_predict_time=`grep rv-predict times.csv | cut -f2 -d','`
none_time=`grep none times.csv | cut -f2 -d','`
dirk_time=`grep dirk times.csv | cut -f2 -d','`

echo "$bname,$dirk_length,$rvp_length,$none_races,$dirk_races,$rvp_races,$run_time,$rv_record_time,$dirk_time,$rv_predict_time" | tee output.csv

echo "$rvp" >> results
echo "$dirk" >> results

ln -s $benchmark/src src
