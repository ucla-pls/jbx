eval "echo \"$settings\"" > petablox.properties
path=`toClasspath $build $libraries`

echo "chord.class.path=$path" >> chord.properties

loadClasspath $jchord 

analyse "jchord" java -Dchord.work.dir=`pwd` \
    chord.project.Boot 

runHook postprocessing
