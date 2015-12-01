source $stdenv/setup

# analyse is a function that logs important information about the
# execution of an analysis. Should be run on each major command in the
# analysis. The first argument is the identifyier of the command, it
# is used directly in the filepaths.
function analyse {
    id=$1
    shift
    export > "../export-$id"
    echo "$@" > "../cmd-$id"

    if $time/bin/time --format "%U,%S,%M" --output "../time-$id" \
		   $@ \
		   1> >($coreutils/bin/tee "../stdout-$id") \
           2> >($coreutils/bin/tee "../stderr-$id" >&2)
    then
        echo "success" >> "../status-$id"
    else
        echo "failed with $?" >> "../status-$id"
    fi
}
export -f analyse

# loadClasspath creates CLASSPATH variable from a list of libraries.
function loadClasspath {
    for l in $@; do
        for ljar in `find $l/share/java -name '*.jar'`; do
            classpath="$classpath${classpath:+':'}$ljar"
        done
    done
    export CLASSPATH="$classpath${classpath:+${CLASSPATH:+':'}}$CLASSPATH"
}
export -f loadClasspath

mkdir -p $out/sandbox

cd $out/sandbox

runHook analysis

cd $out

# Collect all information in files
cat stdout* > stdout
cat stderr* > stderr

cat time* | awk '
BEGIN { FS=","; OFS=","; u = 0; s = 0; m = 0 }
      { u+=$1; s+=$2; if (m < $3) m = $3}
END   { print u, s, m}
' > time 

echo ${env} > env
