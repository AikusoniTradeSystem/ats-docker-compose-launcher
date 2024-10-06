#!/bin/bash

VAULT_CONTAINER_NAME="ats-vault"

echo "Sealing Vault container: $VAULT_CONTAINER_NAME..."

docker exec $VAULT_CONTAINER_NAME vault operator seal

if [ $? -eq 0 ]; then
  echo "Vault has been successfully sealed."
else
  echo "Error: Failed to seal Vault."
fi
