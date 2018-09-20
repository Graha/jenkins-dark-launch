#!/bin/bash
#clean.sh deployed try01
#clean.sh dark try01

DEPLOY_DIR=./.deploy
APP=$1
DEPLOYED=`cat ${DEPLOY_DIR}/deployed.version | tr '.' '-'`
DARK=`cat ${DEPLOY_DIR}/dark.version | tr '.' '-'`
CLEAN=$2
STACK=$3


echo "Finalizing Configuration... However nothing found for this build."
echo "Finalizing Database... However nothing found for this build."
echo "Finalizing Application Cluster... Found"


if [ $CLEAN == 'Rollback' ] || [ $CLEAN == 'B' ] 
then
    echo "Removing ${STACK}_app-${DARK}"
    TD=`docker service inspect ${STACK}_app-${DARK}| grep com.docker.stack.image | cut -f 4 -d "\""`
    docker service rm ${STACK}_app-${DARK} 
    sleep 5
    docker rmi -f ${TD}
    echo "docker service update --env-add ACTIV_APP_ENDPOINT=app-${DEPLOYED} --env-add ALTER_APP_ENDPOINT=app-${DEPLOYED} ${STACK}_app-lb"
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DEPLOYED} --env-add ALTER_APP_ENDPOINT=app-${DEPLOYED} ${STACK}_app-lb
else
    echo "Removing ${STACK}_app-${DEPLOYED}"
    TD=`docker service inspect ${STACK}_app-${DEPLOYED}| grep com.docker.stack.image | cut -f 4 -d "\""`
    docker service rm ${STACK}_app-${DEPLOYED} 
    sleep 5
    docker rmi -f ${TD}
    echo "docker service update --env-add ACTIV_APP_ENDPOINT=app-${DARK} --env-add ALTER_APP_ENDPOINT=app-${DARK} ${STACK}_app-lb"
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DARK} --env-add ALTER_APP_ENDPOINT=app-${DARK} ${STACK}_app-lb
    cp ${DEPLOY_DIR}/dark.version ${DEPLOY_DIR}/deployed.version
fi

rm ${DEPLOY_DIR}/dark.version
