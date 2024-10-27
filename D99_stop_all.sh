#!/bin/bash

(
  source load_env.sh

  docker compose -f 40_docker-compose.develop.yml down -v
  docker compose -f 40_docker-compose.latest.yml down -v
  docker compose -f 30_docker-compose.monitoring.yml down -v
  docker compose -f 20_docker-compose.vault.yml down -v
  docker compose -f 10_docker-compose.db.yml down -v
  docker compose -f 00_docker-compose.network.yml down -v
)
