source $stdenv/setup
source $tools

mkdir $out
cd $out

compose $out $results

for f in $results; do 
    if [ -e "$/may" ]; then
        if [ ! -e may ]; then
            sort -u "$f/may" > may
        else
            comm -12 <(sort -u "$f/may") may > tmp
            mv -f tmp may
        fi
    fi
done | sort -m > may

for f in $results; do 
    sort -u "$f/must"
done | sort -mu > must

for f in $results; do 
    if [ -e "$f/error" ]; then 
        cat "$f/error" >> error; 
    fi
done 


