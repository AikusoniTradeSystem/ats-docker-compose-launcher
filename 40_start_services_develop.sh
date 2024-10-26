#!/bin/bash

(
  source common.sh

  # host environment variables
  export NGINX_LOG_HOME=./logs/nginx
  export TEST_SERVER_SPRING_LOG_HOME=./logs/test-server-spring
  export SESSION_AUTH_SERVER_LOG_HOME=./logs/session-auth-server

  # run docker compose
  docker compose -f 40_docker-compose.develop.yml pull
  docker compose -f 40_docker-compose.develop.yml build --no-cache
  docker compose -f 40_docker-compose.develop.yml up -d
)
