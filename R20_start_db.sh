#!/bin/bash

# ==============================================
# Script Name:	Start Database
# Description:	This script starts the database server container.
# ==============================================

(
  DOCKER_COMPOSE_FILE_NAME="20_docker-compose.db.yml"

  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" pull
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" build --no-cache
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" up -d
)
