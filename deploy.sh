#!/bin/bash
#deploy.sh 1.0 clean try01

VERSION=$1
METHOD=$2
STACK=$3
NORMALIZED_VERSION=`echo ${VERSION} | tr '.' '-'`

mkdir -p ~/.deploy

if [ $METHOD == 'Blue/Green' ] && [ -e ~/.deploy/deployed.version ]
then
    echo "Deploying BlueGreen"
    sed "s/\\\${nversion}/${NORMALIZED_VERSION}/g;s/\\\${version}/${VERSION}/g" docker-delta.yml.t > docker-delta.yml.e
    DEPLOYED=`cat ~/.deploy/deployed.version | tr '.' '-'`
    docker stack deploy -c docker-delta.yml.e ${STACK} 
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DEPLOYED} --env-add ALTER_APP_ENDPOINT=app-${NORMALIZED_VERSION} --env-add ACTIV_APP_PARAM=backup ${STACK}_app-lb
    echo ${VERSION} >  ~/.deploy/dark.version
    cat docker-delta.yml.e
elif [ $METHOD == 'A/B-Testing' ] && [ -e ~/.deploy/deployed.version ]
then
    echo "Deploying ABTesting"
    sed "s/\\\${nversion}/${NORMALIZED_VERSION}/g;s/\\\${version}/${VERSION}/g" docker-delta.yml.t > docker-delta.yml.e
    DEPLOYED=`cat ~/.deploy/deployed.version | tr '.' '-'`
    docker stack deploy -c docker-delta.yml.e ${STACK} 
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DEPLOYED} --env-add ALTER_APP_ENDPOINT=app-${NORMALIZED_VERSION} ${STACK}_app-lb
    echo ${VERSION} > ~/.deploy/dark.version
    cat docker-delta.yml.e
elif [ $METHOD == 'Canary' ] && [ -e ~/.deploy/deployed.version ]
then
    echo "Deploying Canary"
    sed "s/\\\${nversion}/${NORMALIZED_VERSION}/g;s/\\\${version}/${VERSION}/g" docker-delta.yml.t > docker-delta.yml.e
    DEPLOYED=`cat ~/.deploy/deployed.version | tr '.' '-'`
    docker stack deploy -c docker-delta.yml.e ${STACK} 
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DEPLOYED} --env-add ALTER_APP_ENDPOINT=app-${NORMALIZED_VERSION} --env-add ACTIV_APP_PARAM=weight=4 --env-add ALTER_APP_PARAM=weight=1 ${STACK}_app-lb
    echo ${VERSION} > ~/.deploy/dark.version
    cat docker-delta.yml.e
else
    echo "Deploying Clean"
    sed "s/\\\${nversion}/${NORMALIZED_VERSION}/g;s/\\\${version}/${VERSION}/g" docker-clean.yml.t > docker-clean.yml.e
    echo ${VERSION} > ~/.deploy/deployed.version
    docker stack deploy -c docker-clean.yml.e ${STACK}
    cat docker-clean.yml.e
fi

docker service ls 
