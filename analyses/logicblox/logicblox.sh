export LOGICBLOX_HOME=$logicblox4
export LB_WEBSERVER_HOME=$LOGICBLOX_HOME

export PATH=$logicblox4/bin:$python/bin:$procps/bin:$PATH
export HOME=`pwd`


lb services start

runHook lbInner

lb services stop
