#!/bin/bash

(
  export VAULT_CERT_PATH=./certs/vault
  export USER_DB_VAULT_ID="vault_user"
  export USER_DB_VAULT_PW="LR4SO@?9X#+vth7e"

  docker compose -f 20_docker-compose.vault.yml pull
  docker compose -f 20_docker-compose.vault.yml build --no-cache
  docker compose -f 20_docker-compose.vault.yml up -d
)
