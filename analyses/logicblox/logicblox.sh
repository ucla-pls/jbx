source $stdenv/setup

export LOGICBLOX_HOME=$logicblox4
export LB_WEBSERVER_HOME=$LOGICBLOX_HOME

export PATH=$logicblox4/bin:$python/bin:$procps/bin:$jre/bin:${PATH:+':'}$PATH
export HOME=`pwd`

loadClasspath $logicblox4

lb services start >> lb-start

echo "$lbInner"

runHook lbInner

lb services stop >> lb-stop
