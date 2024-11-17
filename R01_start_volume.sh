#!/bin/bash

# ==============================================
# Script Name:	Start Volumes
# Description:	This script creates the Docker volumes for the ATS projects containers.
# ==============================================

(
  DOCKER_COMPOSE_FILE_NAME="01_docker-compose.volume.yml"

  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" pull
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" build --no-cache
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" up -d
)
