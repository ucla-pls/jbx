source $stdenv/setup

set -v 
mkdir -p $out/bin

tail -n +146 "$src" > $out/bin/install
chmod +x $out/bin/install 

pwd
ls -l 

genericBuild
