#!/bin/bash

# ==============================================
# Script Name:  Seal Vault
# Description:  This script seals the Vault container.
# ==============================================

(
  source load_env.sh

  echo -e "Are you sure you want to seal the Vault container: $VAULT_CONTAINER_NAME? (y/n)"
  read -r CONFIRMATION

  if [[ "$CONFIRMATION" == "y" || "$CONFIRMATION" == "Y" ]]; then
    echo -e "Sealing Vault container: $VAULT_CONTAINER_NAME..."

    docker exec $VAULT_CONTAINER_NAME vault operator seal

    if [ $? -eq 0 ]; then
      echo -e "Vault has been successfully sealed."
    else
      echo -e "Error: Failed to seal Vault."
    fi
  else
    echo -e "Operation cancelled. Vault will not be sealed."
  fi
)