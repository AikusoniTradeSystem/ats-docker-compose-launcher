#!/bin/bash

# ==============================================
# Script Name:	Stop Copykeys
# Description:	This script stops the volumes.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker compose -f 06_docker-compose.copy-vault-init-keys.yml down -v
)
