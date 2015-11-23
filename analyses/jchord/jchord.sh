if [ -f "$settings" ]; then
    cat "$settings" > chord.properties
else
    echo "$settings" > chord.properties
fi
export PATH=$jre/bin:$PATH

analyse "jchord" java -cp $jchord/share/java/chord.jar \
	-Dchord.work.dir=`pwd` \
	chord.project.Boot 
