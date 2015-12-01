source $stdenv/setup

mkdir -p $out
echo "$tools"
sed -e "s|\$time|$time|g" \
    -e "s|\$coreutils|$coreutils|g" \
    "$tools" > $out/tools
