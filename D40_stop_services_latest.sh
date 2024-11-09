#!/bin/bash

# ==============================================
# Script Name:  Stop Services (Latest)
# Description:  This script stops the services latest image.
# ==============================================

(
  source load_env.sh
  source load_function.sh

  try docker compose -f 40_docker-compose.latest.yml down -v
)
