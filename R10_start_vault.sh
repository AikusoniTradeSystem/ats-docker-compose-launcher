#!/bin/bash

# ==============================================
# Script Name:	Start Vault
# Description:	This script starts the Vault server container.
# ==============================================

(
  DOCKER_COMPOSE_FILE_NAME="10_docker-compose.vault.yml"

  source load_env.sh
  source load_function.sh

  export VAULT_SERVER_CRT_PATH="${VAULT_SERVER_CERT_FILE_PATH}"
  export VAULT_SERVER_KEY_PATH="${VAULT_SERVER_PRIVATE_KEY_PATH}"
  export VAULT_CA_PATH="${VAULT_SERVER_CERT_FILE_PATH}"

  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" pull
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" build --no-cache
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" up -d
)