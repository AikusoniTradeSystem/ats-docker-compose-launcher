#!/bin/bash

# ==============================================
# Script Name: Stop Services (Develop)
# Description: This script stops the services develop image.
# ==============================================

(
  source load_env.sh
  source load_function.sh

  try docker compose -f 40_docker-compose.develop.yml down -v
)
