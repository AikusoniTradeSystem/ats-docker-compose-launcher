#!/bin/bash
(
  docker compose -f 40_docker-compose.yml down
  docker compose -f 30_docker-compose.monitoring.yml down
  docker compose -f 20_docker-compose.vault.yml down
  docker compose -f 10_docker-compose.db.yml down
  docker compose -f 00_docker-compose.network.yml down
)
