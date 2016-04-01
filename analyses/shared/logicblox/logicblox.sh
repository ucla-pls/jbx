source $stdenv/setup

export LOGICBLOX_HOME=$logicblox
export LB_WEBSERVER_HOME=$LOGICBLOX_HOME

export HOME=`pwd`

lb services start | tee lb_start

runHook lbInner

lb services stop | tee  lb_stop

du -h lb_deployment > lb_stats

if [ ! $keepDatabase ]; then
    rm -r lb_deployment/workspaces
fi
