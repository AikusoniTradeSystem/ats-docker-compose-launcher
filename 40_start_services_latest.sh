#!/bin/bash

(
  source load_env.sh

  # host environment variables
  export NGINX_LOG_HOME=./logs/nginx
  export TEST_SERVER_SPRING_LOG_HOME=./logs/test-server-spring
  export SESSION_AUTH_SERVER_LOG_HOME=./logs/session-auth-server

  # run docker compose
  docker compose -f 40_docker-compose.latest.yml pull
  docker compose -f 40_docker-compose.latest.yml build --no-cache
  docker compose -f 40_docker-compose.latest.yml up -d
)
