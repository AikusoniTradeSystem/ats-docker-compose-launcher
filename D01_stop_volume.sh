#!/bin/bash

# ==============================================
# Script Name:	Stop Volumes
# Description:	This script stops the volumes.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker compose -f 01_docker-compose.volume.yml down -v
)
