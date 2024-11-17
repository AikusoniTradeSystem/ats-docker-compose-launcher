#!/bin/bash

# ==============================================
# Script Name:  Stop Database
# Description:  This script stops the database.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker compose -f 20_docker-compose.db.yml down -v
)
