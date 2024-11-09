#!/bin/bash

# ==============================================
# Script Name:	Start Database
# Description:	This script starts the database server container.
# ==============================================

# TODO 볼트를 통해서 키를 생성하고 해당키를 DB가 서버키로 사용하도록 변경해야함

(
  DOCKER_COMPOSE_FILE_NAME="20_docker-compose.db.yml"

  source load_env.sh
  source load_function.sh

  export USER_DB_SERVER_CRT_PATH="${USER_DB_SERVER_CRYPTO_PATH}/server_self.crt"
  export USER_DB_SERVER_KEY_PATH="${USER_DB_SERVER_CRYPTO_PATH}/server.key"
  export USER_DB_SERVER_SELF_CA_PATH="${USER_DB_CA_CRYPTO_PATH}/ca_self.crt"

  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" pull
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" build --no-cache
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" up -d
)
