#!/bin/bash

# ==============================================
# Script Name:	Start Vault
# Description:	This script starts the Vault server container.
# ==============================================

(
  DOCKER_COMPOSE_FILE_NAME="10_docker-compose.vault.yml"

  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" pull
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" build --no-cache
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" up -d
)