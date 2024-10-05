#!/bin/bash

(
  export PG_DATA=./storage/pg_data
  export VAULT_CERT_PATH=./certs/vault
  export USER_DB_VAULT_ID="vault_acc"
  export USER_DB_VAULT_PW="LR4SO@?9X#+vth7e"

  docker compose -f 10_docker-compose.db.yml pull
  docker compose -f 10_docker-compose.db.yml build --no-cache
  docker compose -f 10_docker-compose.db.yml up -d
)
