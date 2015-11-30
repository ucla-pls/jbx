source $stdenv/setup

export LOGICBLOX_HOME=$logicblox4
export LB_WEBSERVER_HOME=$LOGICBLOX_HOME

export PATH=$logicblox4/bin:$python/bin:$procps/bin:$jre/bin:${PATH:+':'}$PATH
export HOME=`pwd`

for ljar in `find $logicblox4/share/java -name '*.jar'`; do
    if [ "$ljar" = "$target" ]; then
        classpath="$classpath:$ljar"
    fi
done
export CLASSPATH="$classpath${CLASSPATH:+':'}$CLASSPATH"

lb services start >> lb-start

echo "$lbInner"

runHook lbInner

lb services stop >> lb-stop
