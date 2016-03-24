export LOGICBLOX_HOME=$logicblox
export LB_WEBSERVER_HOME=$LOGICBLOX_HOME

export HOME=`pwd`

lb services start >> lb-start

runHook lbInner

lb services stop >> lb-stop

du -h lb_deployment > lb_stats

if [ ! $keepDatabase ]; then
    rm -r lb_deployment/workspaces
fi
