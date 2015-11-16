source $stdenv/setup

mkdir -p $out/sandbox
cd $out/sandbox

if [ $input ]; then
    echo $input
fi

$time/bin/time --output ../time $cmd $cmdargs 1> ../stdout 2> ../stderr || true

