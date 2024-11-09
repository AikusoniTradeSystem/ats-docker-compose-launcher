#!/bin/bash

# ==============================================
# Script Name:	Start Networks
# Description:	This script creates the Docker networks for the ATS Project.
# ==============================================

(
  DOCKER_COMPOSE_FILE_NAME="00_docker-compose.network.yml"

  source load_env.sh
  source load_function.sh

  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" pull
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" build --no-cache
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" up -d
)
