#!/bin/bash

# Inspect the disassembled .class files in the jar for java reflection
javap -p -c -classpath $classpath \
    $(jar -tf $classpath | grep "class$" | sed s/\.class$//) | \
    grep -qE "java[\.\/]lang[\.\/](reflect|Class\.newInstance)"

if [ $? -eq 0 ]; then
    echo "yes" > $out/upper
    echo "Benchmark $name utilizes reflection"
else
    touch $out/upper # create empty upper file
    echo "Benchmark $name does not utilize reflection"
fi
