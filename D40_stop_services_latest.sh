#!/bin/bash

# ==============================================
# Script Name:  Stop Services (Latest)
# Description:  This script stops the services latest image.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker compose -f 40_docker-compose.latest.yml down -v
)
