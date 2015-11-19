if [ -f "$settings" ]; then
    cat "$settings" > chord.properties
else
    echo "$settings" > chord.properties
fi

export PATH=$jre/bin:$logicblox4/bin:$PATH

# As in the petablox/provision/startlb.sh
source $logicblox4/etc/profile.d/logicblox.sh

cat "$logicblox4/etc/profile.d/logicblox.sh"
lb-services start

analyse "jchord" java -cp $jchord/share/java/chord.jar \
	-Dchord.work.dir=`pwd` \
	chord.project.Boot 
