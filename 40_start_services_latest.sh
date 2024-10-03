#!/bin/bash

(
  # host environment variables
  export NGINX_LOG_HOME=./logs/nginx
  export TEST_SERVER_SPRING_LOG_HOME=./logs/test-server-spring
  export SESSION_AUTH_SERVER_LOG_HOME=./logs/session-auth-server
  
  # You can add more environment variables here (See 40_docker-compose.yml)

  # run docker compose
  docker compose -f 40_docker-compose.yml pull
  docker compose -f 40_docker-compose.yml build --no-cache
  docker compose -f 40_docker-compose.yml up -d
)
