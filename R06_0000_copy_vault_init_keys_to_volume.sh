#!/bin/bash

# ==============================================
# Script Name:	Generate Vault Crypto
# Description:	This script generates the Vault server and client crypto.
# ==============================================

(
  DOCKER_COMPOSE_FILE_NAME="06_docker-compose.copy-vault-init-keys.yml"

  source CMN_load_env.sh
  source CMN_load_function.sh

  SERVER_PRIVATE_KEY_PATH="${VAULT_SERVER_PRIVATE_KEY_PATH}"
  SERVER_CERT_FILE_PATH="${VAULT_SERVER_CERT_FILE_PATH}"
  SERVER_PUBLIC_CHAIN_CERT_PATH="${VAULT_SERVER_PUBLIC_CHAIN_CERT_PATH}"

  export VAULT_INIT_KEYS_CONTAINER_NAME="vault-init-keys-container"

  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" up -d

  log d "Copy the generated crypto to the Vault Volume..."
  try docker cp "${SERVER_PRIVATE_KEY_PATH}" "${VAULT_INIT_KEYS_CONTAINER_NAME}:/vault/init-keys/server.key"
  try docker cp "${SERVER_CERT_FILE_PATH}" "${VAULT_INIT_KEYS_CONTAINER_NAME}:/vault/init-keys/server.crt"
  try docker cp "${SERVER_PUBLIC_CHAIN_CERT_PATH}" "${VAULT_INIT_KEYS_CONTAINER_NAME}:/vault/init-keys/full_chain.crt"

  # Change the owner and permissions of the generated crypto
  log d "Change the owner and permissions of the generated crypto..."
  try docker exec ${VAULT_INIT_KEYS_CONTAINER_NAME} addgroup -S vault
  try docker exec ${VAULT_INIT_KEYS_CONTAINER_NAME} adduser -S vault -G vault
  try docker exec ${VAULT_INIT_KEYS_CONTAINER_NAME} chown vault:vault /vault/init-keys/server.crt /vault/init-keys/server.key /vault/init-keys/full_chain.crt
  try docker exec ${VAULT_INIT_KEYS_CONTAINER_NAME} chmod 640 /vault/init-keys/server.key
  try docker exec ${VAULT_INIT_KEYS_CONTAINER_NAME} chmod 644 /vault/init-keys/server.crt
  try docker exec ${VAULT_INIT_KEYS_CONTAINER_NAME} chmod 644 /vault/init-keys/full_chain.crt

  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" stop
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" rm -f
  log i "Vault Crypto generated successfully."
)