#!/bin/bash

(
  docker compose -f 20_docker-compose.vault.yml pull
  docker compose -f 20_docker-compose.vault.yml build --no-cache
  docker compose -f 20_docker-compose.vault.yml up -d
)
