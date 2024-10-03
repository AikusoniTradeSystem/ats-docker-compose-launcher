#!/bin/bash

(
  # host environment variables
  export NGINX_LOG_HOME=./logs/nginx
  export TEST_SERVER_SPRING_LOG_HOME=./logs/test-server-spring
  export SESSION_AUTH_SERVER_LOG_HOME=./logs/session-auth-server
  

  # run docker compose
  # If you want to use dev image, use the following command
  docker compose -f 40_docker-compose.dev.yml pull 
  docker compose -f 40_docker-compose.dev.yml build --no-cache
  docker compose -f 40_docker-compose.dev.yml up -d
)
