#!/bin/bash
#deploy.sh 1.0 clean try01

VERSION=$1
METHOD=$2
STACK=$3
NORMALIZED_VERSION=`echo ${VERSION} | tr '.' '-'`

if [ $METHOD == 'bg' ] && [ -e deployed.version ]
then
    echo "Deploying BlueGreen"
    sed "s/\\\${nversion}/${NORMALIZED_VERSION}/g;s/\\\${version}/${VERSION}/g" docker-delta.yml.t > docker-delta.yml.e
    DEPLOYED=`cat deployed.version | tr '.' '-'`
    docker stack deploy -c docker-delta.yml.e ${STACK} 
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DEPLOYED} --env-add ALTER_APP_ENDPOINT=app-${NORMALIZED_VERSION} --env-add ALTER_APP_PARAM=backup ${STACK}_app-lb
    echo ${VERSION} > dark.version
elif [ $METHOD == 'ab' ] && [ -e deployed.version ]
then
    echo "Deploying ABTesting"
    sed "s/\\\${nversion}/${NORMALIZED_VERSION}/g;s/\\\${version}/${VERSION}/g" docker-delta.yml.t > docker-delta.yml.e
    DEPLOYED=`cat deployed.version | tr '.' '-'`
    docker stack deploy -c docker-delta.yml.e ${STACK} 
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DEPLOYED} --env-add ALTER_APP_ENDPOINT=app-${NORMALIZED_VERSION} ${STACK}_app-lb
    echo ${VERSION} > dark.version
elif [ $METHOD == 'can' ] && [ -e deployed.version ]
then
    echo "Deploying Canary"
    sed "s/\\\${nversion}/${NORMALIZED_VERSION}/g;s/\\\${version}/${VERSION}/g" docker-delta.yml.t > docker-delta.yml.e
    DEPLOYED=`cat deployed.version | tr '.' '-'`
    docker stack deploy -c docker-delta.yml.e ${STACK} 
    docker service update --env-add ACTIV_APP_ENDPOINT=app-${DEPLOYED} --env-add ALTER_APP_ENDPOINT=app-${NORMALIZED_VERSION} --env-add ACTIV_APP_PARAM=weight=4 --env-add ALTER_APP_PARAM=weight=1 ${STACK}_app-lb
    echo ${VERSION} > dark.version
else
    echo "Deploying Clean"
    sed "s/\\\${nversion}/${NORMALIZED_VERSION}/g;s/\\\${version}/${VERSION}/g" docker-clean.yml.t > docker-clean.yml.e
    echo ${VERSION} > deployed.version
    docker stack deploy -c docker-clean.yml.e ${STACK}
fi