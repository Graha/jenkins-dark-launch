#ABTesting
#docker service update --env-add ACTIV_APP_ENDPOINT=app-activ --env-add ALTER_APP_ENDPOINT=app-alter try01_lb-app
#BG
#docker service update --env-add ACTIV_APP_ENDPOINT=app-activ --env-add ALTER_APP_ENDPOINT=app-alter --env-add ALTER_APP_PARAM=backup  try01_lb-app
#Canary
#docker service update --env-add ACTIV_APP_ENDPOINT=app-activ --env-add ALTER_APP_ENDPOINT=app-alter --env-add ACTIV_APP_PARAM=weight=4 --env-add ALTER_APP_PARAM=weight=1  try01_lb-app
version: '3'
services:
  app-${nversion}:
    image: relevancelab/cc:${version}
    environment:
      - DB_HOST=172.17.2.4
      - REDIS_HOST=172.17.2.4
      - SCHEDULER_HOST=scheduler
      - APP_ENV=QA
    volumes:
      - /opt/cc/config:/rlc/cc/server/app/config
      - /opt/cc/logs:/rlc/cc/server/app/logs