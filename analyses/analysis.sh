source $stdenv/setup

# analyse is a function that logs important information about the
# execution of an analysis. Should be run on each mayor command in the
# analysis. The first argument is the identifyier of the command, it
# is used directly in the filepaths.
function analyse {
    id=$1
    shift
    $time/bin/time --format "%U,%S,%M" --output "../time-$id" \
		   $@ \
		   1> "../stdout-$id" \
		   2> "../stderr-$id" || true
}

mkdir -p $out/sandbox

cd $out/sandbox

if [ -f $analysis ]; then
    source $analysis
else # its a string.
    $(analysis)
fi

cd $out

# Collect all information in files
cat stdout* > stdout
cat stderr* > stderr

cat time* | awk '
BEGIN { FS=","; u = 0; s = 0; m = 0 }
{u+=$1; s+=$2; if (m < $3) m = $3}
END {print u, s, m}
' > time 

echo ${env} > env
