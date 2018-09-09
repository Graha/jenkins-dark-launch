#!/bin/bash
#clean.sh deployed try01
#clean.sh dark try01

DEPLOYED=`cat deployed.version | tr '.' '-'`
DARK=`cat dark.version | tr '.' '-'`
CLEAN=$1
STACK=$2


if [ $CLEAN == 'deployed' ]
then
    echo "Removing ${STACK}_app-${DEPLOYED}"
    docker service rm ${STACK}_app-${DEPLOYED} 
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DARK} --env-add ALTER_APP_ENDPOINT=app-${DARK} ${STACK}_app-lb
    cp dark.version deployed.version
else
    echo "Removing ${STACK}_app-${DARK}"
    docker service rm ${STACK}_app-${DARK} 
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DEPLOYED} --env-add ALTER_APP_ENDPOINT=app-${DEPLOYED} ${STACK}_app-lb
fi

rm dark.version