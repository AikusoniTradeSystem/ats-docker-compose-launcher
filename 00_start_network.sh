#!/bin/bash

(
  source load_env.sh

  docker compose -f 00_docker-compose.network.yml pull
  docker compose -f 00_docker-compose.network.yml build --no-cache
  docker compose -f 00_docker-compose.network.yml up -d
)
