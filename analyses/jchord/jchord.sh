if [ -f "$settings" ]; then
    cat "$settings" > chord.properties
else
    echo "$settings" > chord.properties
fi

export LOGICBLOX_HOME=$logicblox4
export LB_WEBSERVER_HOME=$LOGICBLOX_HOME

export PATH=$jre/bin:$logicblox4/bin:$PATH:$python/bin:$procps/bin
export HOME=`pwd`


lb services start

analyse "jchord" java -cp $jchord/share/java/chord.jar \
	-Dchord.work.dir=`pwd` \
	chord.project.Boot 

lb services stop
