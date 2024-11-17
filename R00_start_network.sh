#!/bin/bash

# ==============================================
# Script Name:	Start Networks
# Description:	This script creates the Docker networks for the ATS Project.
# ==============================================

(
  DOCKER_COMPOSE_FILE_NAME="00_docker-compose.network.yml"

  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" pull
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" build --no-cache
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" up -d
)
