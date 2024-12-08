#!/bin/bash

# ==============================================
# Script Name:	Update User Database SSL Key
# Description:	This script updates the SSL key for the user database.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  DOCKER_COMPOSE_FILE_NAME="20_docker-compose.db.yml"

  TEMP_KEY="$$"
  SERVICE_NAME="ats-user-db"
  TEMP_DIR=$(create_temp_dir "${TEMP_KEY}")
  VAULT_PKI_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/pki-policy.json")
  ACCESS_CA_CERT_PATH="${INTER_CA2_PUBLIC_CHAIN_CERT_PATH}"
  BARE_HOST_NAME="${BARE_HOST_NAME}"
  SERVER_CONTAINER_NAME="${USER_DB_CONTAINER_NAME}"
  SERVER_HOST_NAME="${USER_DB_HOST_NAME}"
  SERVER_PKI_ROLE_NAME="${SERVER_CONTAINER_NAME}-role"
  TEMP_PRIVATE_KEY_PATH="${TEMP_DIR}/private.key"
  TEMP_CSR_PATH="${TEMP_DIR}/request.csr"
  TEMP_CERTIFICATE_PATH="${TEMP_DIR}/certificate.crt"
  TEMP_CA_CHAIN_PATH="${TEMP_DIR}/ca-chain.crt"
  CONTAINER_PRIVATE_KEY_PATH="${USER_DB_CERT_PATH_IN_CONTAINER}/server.key"
  CONTAINER_CERTIFICATE_PATH="${USER_DB_CERT_PATH_IN_CONTAINER}/server.crt"
  CONTAINER_CA_CHAIN_PATH="${USER_DB_CERT_PATH_IN_CONTAINER}/ca.crt"

  try ./CMN_generate_and_sign_server_key.sh \
    --vault_pki_token="${VAULT_PKI_POLICY_TOKEN}" \
    --access_ca_cert_path="${ACCESS_CA_CERT_PATH}" \
    --bare_host_name="${BARE_HOST_NAME}" \
    --server_container_name="${SERVER_CONTAINER_NAME}" \
    --server_host_name="${SERVER_HOST_NAME}" \
    --server_pki_role_name="${SERVER_PKI_ROLE_NAME}" \
    --private_key_output_path="${TEMP_PRIVATE_KEY_PATH}" \
    --csr_output_path="${TEMP_CSR_PATH}" \
    --certificate_output_path="${TEMP_CERTIFICATE_PATH}" \
    --ca_chain_output_path="${TEMP_CA_CHAIN_PATH}"

  try docker cp "${TEMP_PRIVATE_KEY_PATH}" "${SERVER_CONTAINER_NAME}":"${CONTAINER_PRIVATE_KEY_PATH}"
  try docker cp "${TEMP_CERTIFICATE_PATH}" "${SERVER_CONTAINER_NAME}":"${CONTAINER_CERTIFICATE_PATH}"
  try docker cp "${TEMP_CA_CHAIN_PATH}" "${SERVER_CONTAINER_NAME}":"${CONTAINER_CA_CHAIN_PATH}"

  try docker exec --user root "${SERVER_CONTAINER_NAME}" bash -c "
    chown postgres:postgres '${CONTAINER_PRIVATE_KEY_PATH}' '${CONTAINER_CERTIFICATE_PATH}' '${CONTAINER_CA_CHAIN_PATH}' &&
    chmod 600 '${CONTAINER_PRIVATE_KEY_PATH}' &&
    chmod 644 '${CONTAINER_CERTIFICATE_PATH}' &&
    chmod 644 '${CONTAINER_CA_CHAIN_PATH}'
  "

  # Restart the server container to apply the new SSL key
  # TODO Rolling restart for production
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" restart "${SERVICE_NAME}"

  print_temp_dirs "${TEMP_KEY}"
  cleanup_temp_dirs "${TEMP_KEY}"
)
