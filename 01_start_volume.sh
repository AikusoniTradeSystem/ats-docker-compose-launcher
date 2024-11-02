#!/bin/bash

(
  source load_env.sh

  docker compose -f 01_docker-compose.volume.yml pull
  docker compose -f 01_docker-compose.volume.yml build --no-cache
  docker compose -f 01_docker-compose.volume.yml up -d
)
