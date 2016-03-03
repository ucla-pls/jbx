source $stdenv/setup

function toClasspath {
    local classpath=""
    for l in $@; do
        for ljar in `find $l/share/java -name '*.jar'`; do
            classpath="$classpath${classpath:+:}$ljar"
        done
    done
    echo "$classpath"
}
export -f toClasspath

# loadClasspath creates CLASSPATH variable from a list of libraries.
function loadClasspath {
    local classpath=`toClasspath $@`
    export CLASSPATH="$classpath${classpath:+${CLASSPATH:+:}}$CLASSPATH"
}
export -f loadClasspath

HEADER="name,real,user,kernel,maxm,exitcode"

function compose {
    local folder=$1; shift
    mkdir -p "$folder"
    echo "$HEADER" > "$folder/times.csv"
    for f in $@; do 
        local name=`basename $f`
        echo "$f" >> "$folder/compose.txt"
        tail -n +2 "$f/times.csv" >> "$folder/times.csv"
        
        echo "# START >>> $name" >> "$folder/stdout"
        cat "$f/stdout" >> "$folder/stdout"
        echo "# END >>> $name" >> "$folder/stdout"
        
        echo "# START >>> $name" >> "$folder/stderr"
        cat "$f/stderr" >> "$folder/stderr"
        echo "# END >>> $name" >> "$folder/stderr"
    done
}
export -f compose

# record records everything
function record {
    local id=$1
    local folder=$2
    local timelimit=$3
    shift; shift; shift;
    mkdir -p "$folder"

    export > "$folder/export"
    echo "$@" > "$folder/cmd"

    echo "$HEADER" > "$folder/times.csv"

    touch "$folder/stderr" "$folder/stdout"
   
    timeout ${timelimit} $time/bin/time \
        --format "$id,%e,%U,%S,%M,%x" \
        --output "$folder/times.csv" \
        --append \
        $@ \
        1> >($coreutils/bin/tee "$folder/stdout") \
        2> >($coreutils/bin/tee "$folder/stderr" >&2) || true

    if ! grep "$id" "$folder/times.csv" ; then
        echo "$id,${timelimit},N/A,N/A,N/A,N/A" >> "$folder/times.csv"
    fi
    sed -i -e "/Command/d" "$folder/times.csv"

} 
export -f record

function evalArgs {
    local args=""
    for i in $inputargs; do
        local arg=`eval "echo $i"`
        local args="$args $arg"
    done
    echo "$args"
}
export -f evalArgs
