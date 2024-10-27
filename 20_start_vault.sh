#!/bin/bash

(
  source load_env.sh

  export VAULT_SERVER_CRT_PATH="${VAULT_SERVER_CRYPTO_PATH}/server.crt"
  export VAULT_SERVER_KEY_PATH="${VAULT_SERVER_CRYPTO_PATH}/server.key"
  export VAULT_CA_PATH="${VAULT_CA_CRYPTO_PATH}/ca.crt"

  docker compose -f 20_docker-compose.vault.yml pull
  docker compose -f 20_docker-compose.vault.yml build --no-cache
  docker compose -f 20_docker-compose.vault.yml up -d
)
