#!/bin/bash

(
  export INTERNAL_NETWORK_INTERNAL=true
  export VAULT_NETWORK_INTERNAL=true
  export MONITORING_NETWORK_INTERNAL=false

  docker compose -f 00_docker-compose.network.yml pull
  docker compose -f 00_docker-compose.network.yml build --no-cache
  docker compose -f 00_docker-compose.network.yml up -d
)
