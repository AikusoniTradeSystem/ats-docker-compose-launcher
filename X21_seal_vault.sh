#!/bin/bash

VAULT_CONTAINER_NAME="ats-vault"

echo "Are you sure you want to seal the Vault container: $VAULT_CONTAINER_NAME? (y/n)"
read -r CONFIRMATION

if [[ "$CONFIRMATION" == "y" || "$CONFIRMATION" == "Y" ]]; then
  echo "Sealing Vault container: $VAULT_CONTAINER_NAME..."

  docker exec $VAULT_CONTAINER_NAME vault operator seal

  if [ $? -eq 0 ]; then
    echo "Vault has been successfully sealed."
  else
    echo "Error: Failed to seal Vault."
  fi
else
  echo "Operation cancelled. Vault will not be sealed."
fi
