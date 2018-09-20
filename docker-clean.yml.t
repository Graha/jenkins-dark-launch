version: '3'
services:
  app-lb:
    image: nginx
    command: /bin/bash -c "envsubst < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'" 
    volumes:
      - ./nginx.template:/etc/nginx/conf.d/default.template 
    environment:
    - ACTIV_APP_ENDPOINT=app-${nversion}
    - ALTER_APP_ENDPOINT=app-${nversion}
    - ACTIV_APP_PARAM=
    - ALTER_APP_PARAM=    
    ports:
    - 80:80
    deploy:
      replicas: 2
      update_config:
        parallelism: 1
        delay: 0s
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
