source $stdenv/setup

args=`evalArgs $inputargs`

loadClasspath $build $libraries

runHook setup

analyse "run" java $mainclass $args < ${stdin:-/dev/null}

# Export results
touch ../may ../must
if [[ $RETVAL -eq 0 ]]; then
    printf "$mainclass $args\t$(md5sum ${stdin:-/dev/null})" > ../may
else
    echo "Program failed with $RETVAL" > ../error
fi

