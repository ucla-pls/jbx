#!/bin/bash

# Inspect the disassembled .class files in the jar for java reflection
echo "Methods utilizing reflection:"
javap -p -c -classpath $classpath \
    $(jar -tf $classpath | grep "class$" | sed s/\.class$//) | \
    grep -oE "\/\/Method java\/lang\/((reflect\/(Method\.invoke|Constructor\.newInstance))|(Class\.newInstance)).*$" | \
    sed 's/\/\/Method\s//' | tee $out/upper
echo

# Find the number of reflection methods
# Using grep instead of 'wc -l' since wc also prints the path of the file
nmethods=`grep -c $ $out/upper`
echo "Number of reflection methods: $nmethods"

if [ "$nmethods" -eq 0 ]; then
    echo "$name does not utilize reflection"
else
    # Since this is an overapproximation, even if reflection methods are
    # found, it cannot be definitively said that the benchmark utilizes
    # reflection for all executions.
    echo "$name may utilize reflection"
fi
