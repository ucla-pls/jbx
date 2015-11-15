source $stdenv/setup

mkdir -p $out/sandbox
cd $out/sandbox

$time/bin/time --output ../time $cmd $cmdargs 1> ../stdout 2> ../stderr || true

