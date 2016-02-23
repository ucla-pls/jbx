eval "echo \"$settings\"" > chord.properties
path=`toClasspath $build $libraries`

echo "chord.class.path=$path" >> chord.properties

analyse "jchord" java -Dchord.work.dir=`pwd` \
    chord.project.Boot 
