#!/bin/bash

# ==============================================
# Script Name:  Stop Database
# Description:  This script stops the database.
# ==============================================

(
  source load_env.sh
  source load_function.sh

  try docker compose -f 20_docker-compose.db.yml down -v
)
