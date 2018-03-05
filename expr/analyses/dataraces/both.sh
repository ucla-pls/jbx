source $stdenv/setup

mkdir $out
cd $out


runHook setup

none_races=`wc -l $dirk/none.dataraces.txt | cut -f1 -d' '`
dirk_races=`wc -l $dirk/dirk.dataraces.txt | cut -f1 -d' '`
rvp_races=`wc -l $rvp/lower | cut -f1 -d' '`
dirk_length=`cat $dirk/history.size.txt`
rvp_length=`grep "Trace Size: " $rvp/rv-predict/stdout | cut -d' ' -f3`


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
