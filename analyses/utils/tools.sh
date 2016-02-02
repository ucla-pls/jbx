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

function loadTools {
    local path=""
    for l in $@; do
        if [ -d "$l/bin" ]; then
            path="$path${path:+:}$l/bin"
        fi
    done
    export PATH="$path${path:+${PATH:+:}}$PATH"
}
export -f loadTools

HEADER="name,user,kernel,maxm,exitcode"

# joinResults joins a list of base csv files and prints the resulting csv file
function compose {
    local folder=$1; shift
    mkdir -p "$folder"
    echo "$HEADER" > "$folder/base.csv"
    for f in $@; do 
        local name=`basename $f`
        echo "$f" >> "$folder/compose.txt"
        tail -n +2 "$f/base.csv" >> "$folder/base.csv"
        
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

    echo "$HEADER" > "$folder/base.csv"
   
    timeout ${timelimit} $time/bin/time \
        --format "$id,%U,%S,%M,%x" \
        --output "$folder/base.csv" \
        --append \
        $@ \
        1> >($coreutils/bin/tee "$folder/stdout") \
        2> >($coreutils/bin/tee "$folder/stderr" >&2) || true

    if grep "$id" "$folder/base.csv" ; then
        sed -i -e "/Command exited with non-zero status/d" "$folder/base.csv"
    else
        echo "$id,N/A,N/A,N/A,N/A" >> "$folder/base.csv"
    fi

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
