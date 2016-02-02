source $stdenv/setup
# source $utils/tools

mkdir $out
cd $out

function compose {
    local folder=$1; shift
    mkdir -p "$folder"
    echo "$HEADER" > "$folder/base.csv"
    for f in $@; do 
        local name=`basename $f`
        echo "$f" >> "$folder/compose.txt"
        tail -n +2 "$f/base.csv" >> "$folder/base.csv"
        
        # echo "# START >>> $name" >> "$folder/stdout"
        # cat "$f/stdout" >> "$folder/stdout"
        # echo "# END >>> $name" >> "$folder/stdout"
        # 
        # echo "# START >>> $name" >> "$folder/stderr"
        # cat "$f/stderr" >> "$folder/stderr"
        # echo "# END >>> $name" >> "$folder/stderr"
    done
}
export -f compose


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
