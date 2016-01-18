
if [ -f "$settings" ]; then
    cat "$settings" > petablox.properties
else
    echo "$settings" > petablox.properties
fi
path=`toClasspath $build $libraries`

echo "petablox.class.path=$path" >> petablox.properties

# echo $CLASSPATH

analyse "petablox" java -Dpetablox.work.dir=`pwd` \
    petablox.project.Boot 

# runHook postprocessing
