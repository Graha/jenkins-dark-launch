#!/bin/bash
#clean.sh deployed try01
#clean.sh dark try01

DEPLOYED=`cat ~/.deploy/deployed.version | tr '.' '-'`
DARK=`cat ~/.deploy/dark.version | tr '.' '-'`
CLEAN=$1
STACK=$2


if [ $CLEAN == 'Rollback' ] || [ $CLEAN == 'B' ] 
    echo "Removing ${STACK}_app-${DARK}"
    TD=`docker service inspect ${STACK}_app-${DARK}| grep com.docker.stack.image | cut -f 4 -d "\""`
    docker service rm ${STACK}_app-${DARK} 
    sleep 5
    docker rmi -f ${TD}
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DEPLOYED} --env-add ALTER_APP_ENDPOINT=app-${DEPLOYED} ${STACK}_app-lb
else
    echo "Removing ${STACK}_app-${DEPLOYED}"
    TD=`docker service inspect ${STACK}_app-${DEPLOYED}| grep com.docker.stack.image | cut -f 4 -d "\""`
    docker service rm ${STACK}_app-${DEPLOYED} 
    sleep 5
    docker rmi -f ${TD}
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DARK} --env-add ALTER_APP_ENDPOINT=app-${DARK} ${STACK}_app-lb
    cp ~/.deploy/dark.version ~/.deploy/deployed.version
fi

rm ~/.deploy/dark.version
