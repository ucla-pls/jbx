#!/bin/bash

# Find the classes
declare -a classes
readarray -t classes < <(jar -tf $classpath | grep "class$" | sed 's/\.class$//g')

# For each class disassemble the file and record the output
# Iterate through each line of output, recording the current method,
# internal type signature, and reflection methods.
declare -a reflection_methods
for class in "${classes[@]}"; do
    cls=`echo "$class" | sed 's/\//\./g'`
    while IFS= read -r line; do
        # Method or constructor declaration
        tmp_method=`echo $line | sed -n 's/(.*);$//p'`
        if [ -n "$tmp_method" ]; then 
            split=($tmp_method); method="${split[@]: -1:1}"
            if [ $method == $cls ]; then method="<init>"; fi
        fi

        # Static initializer
        echo $line | grep -qE "static \{\}"
        if [ "$?" -eq 0 ]; then method="<clinit>"; fi

        # Internal type signature
        tmp_descr=`echo $line | sed -n 's/Signature: //p'`
        if [ -n "$tmp_descr" ]; then signature="$tmp_descr"; fi

        # Reflection method
        echo $line | grep -qE "Method java\/lang\/((reflect\/(Method\.invoke|Constructor\.newInstance))|(Class\.newInstance)).*$"
        if [ "$?" -eq 0 ]; then
            reflection_methods+=("$class.$method:$signature");
        fi
    done < <(javap -p -c -s -classpath $classpath $class)
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
