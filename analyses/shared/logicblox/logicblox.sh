source $stdenv/setup

export LOGICBLOX_HOME=$logicblox
export LB_WEBSERVER_HOME=$LOGICBLOX_HOME

export HOME=`pwd`

lb services start >> lb-start

runHook lbInner

lb services stop >> lb-stop
