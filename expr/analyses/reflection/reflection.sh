#!/bin/bash

# Find the classes
declare -a classes
readarray -t classes < <(jar -tf $classpath | grep "class$" | sed 's/\.class$//g')

# TODO: Add classes on the classpath that are not in the jar?

# For each class disassemble the file and record the output
# Iterate through each line of output, recording the current method
# and output a reflection method if found.
declare -a reflection_methods
for class in ${classes[@]}; do
    declare method
    declare lastline
        while IFS= read -r line; do
            echo $line | grep -oqE "^Code:$"
            if [ $? -eq 0 ]; then
                # Get the method name from the last line
                method="$lastline"
            else
                echo $line | grep -oqE "java\/lang\/((reflect\/(Method\.invoke|Constructor\.newInstance))|(Class\.newInstance)).*$"
                if [ $? -eq 0 ]; then
                    # Append method to the array of reflection methods
                    reflection_methods+=("$method")
                fi
            fi
            lastline=$line
        done < <(javap -p -c -classpath $classpath $class)
done

# Sort the reflection_methods and remove duplicates
declare -a sorted
readarray -t sorted < <(printf '%s\n' "${reflection_methods[@]}" | sort -u)
echo "Methods utilizing reflection:"
printf '%s\n' "${sorted[@]}" | tee "$out/upper"; echo

if [ "${#sorted[@]}" -eq 0 ]; then
    echo "$name does not utilize reflection"
else
    # Since this is an overapproximation, even if reflection methods are
    # found, it cannot be definitively said that the benchmark utilizes
    # reflection for all executions.
    echo "$name may utilize reflection"
fi
