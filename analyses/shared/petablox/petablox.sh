export | grep /var/empty

eval "echo \"$settings\"" > petablox.properties
path=`toClasspath $build $libraries`

echo "petablox.class.path=$path" >> petablox.properties

# echo $CLASSPATH

analyse "petablox" java -Dpetablox.work.dir=`pwd` \
    petablox.project.Boot 

# runHook postprocessing
