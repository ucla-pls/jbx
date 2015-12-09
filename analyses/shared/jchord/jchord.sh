if [ -f "$settings" ]; then
    cat "$settings" > chord.properties
else
    echo "$settings" > chord.properties
fi
path=`toClasspath $build $libraries`
echo "chord.class.path=$path" >> chord.properties
export PATH=$jre/bin:$PATH

loadClasspath $jchord 

analyse "jchord" java -Dchord.work.dir=`pwd` \
    chord.project.Boot 
