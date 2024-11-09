#!/bin/bash

# ==============================================
# Script Name:  Stop Vault
# Description:  This script stops the vault.
# ==============================================

(
  source load_env.sh
  source load_function.sh

  try docker compose -f 10_docker-compose.vault.yml down -v
)
