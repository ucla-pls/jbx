source $stdenv/setup
source $tools

mkdir $out
cd $out

compose $out $results

for f in $results; do 
    # May analyses has to be pressent in all analyses.
    if [ -e "$f/may" ]; then
        if [ ! -e may ]; then 
            cp "$f/may" may
        else
            comm -12 "$f/may" may > tmp
            mv -f tmp may
        fi
    fi
    # The Must analysis just have to be there
    if [ -e "$f/must" ]; then
        if [ ! -e must ]; then 
            cp "$f/must" must
        else
            sort -m "$f/must" must | uniq > tmp
            mv -f tmp must
        fi
    fi
done 

for f in $results; do 
    if [ -e "$f/error" ]; then 
        cat "$f/error" >> error; 
    fi
done 


