#!/bin/bash

(
  source load_env.sh

  export USER_DB_SERVER_CRT_PATH="${USER_DB_SERVER_CRYPTO_PATH}/server_self.crt"
  export USER_DB_SERVER_KEY_PATH="${USER_DB_SERVER_CRYPTO_PATH}/server.key"
  export USER_DB_CA_PATH="${USER_DB_CA_CRYPTO_PATH}/ca.crt"

  docker compose -f 10_docker-compose.db.yml pull
  docker compose -f 10_docker-compose.db.yml build --no-cache
  docker compose -f 10_docker-compose.db.yml up -d
)
