#!/bin/bash

# ==============================================
# Script Name:	Register User Database Client Key to Vault
# Description:	This script registers the client key for the user database in Vault.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  TEMP_KEY="$$"
  SERVICE_NAME="ats-user-db"
  TEMP_DIR=$(create_temp_dir "${TEMP_KEY}")
  DB_VAULT_ID="${USER_DB_VAULT_ID}"
  DB_VAULT_PW="${USER_DB_VAULT_PW}"
  VAULT_PKI_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/pki-policy.json")
  ACCESS_CA_CERT_PATH="${INTER_CA2_PUBLIC_CHAIN_CERT_PATH}"
  CLIENT_PKI_ROLE_NAME="${USER_DB_CONTAINER_NAME}-client-role"
  TEMP_PRIVATE_KEY_PATH="${TEMP_DIR}/private.key"
  TEMP_CERTIFICATE_PATH="${TEMP_DIR}/certificate.crt"
  TEMP_CA_CHAIN_PATH="${TEMP_DIR}/ca-chain.crt"

  DB_ALIAS="${USER_DB_APPROLE_ALIAS}"
  DB_NAME="${USER_DB_SERVICE_NAME}"
  DB_HOST="${USER_DB_HOST_NAME}"
  DB_PORT="${USER_DB_PORT}"

  log i "Generate and Sign Client Key"
  # Generate a client key for the vault to connect to the user database (It is singed by vault itself)
  try ./CMN_generate_and_sign_client_key.sh \
    --vault_pki_token="${VAULT_PKI_POLICY_TOKEN}" \
    --access_ca_cert_path="${ACCESS_CA_CERT_PATH}" \
    --client_pki_role_name="${CLIENT_PKI_ROLE_NAME}" \
    --client_common_name="client.internal" \
    --client_alt_names="${DB_VAULT_ID}" \
    --private_key_output_path="${TEMP_PRIVATE_KEY_PATH}" \
    --certificate_output_path="${TEMP_CERTIFICATE_PATH}" \
    --ca_chain_output_path="${TEMP_CA_CHAIN_PATH}"

  # copy the client key to the vault container
  log i "Copy the client key to the vault container"
  SSL_MODE="verify-full"
  SSL_CA_CHAIN="${TEMP_CA_CHAIN_PATH}"
  SSL_SRC_CERT="${TEMP_CERTIFICATE_PATH}"
  SSL_SRC_KEY="${TEMP_PRIVATE_KEY_PATH}"
  DB_VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/database-policy.json")

  ./R23_BASE_00_configure_vault_db.sh \
    --db_vault_id="$DB_VAULT_ID" \
    --db_vault_pw="$DB_VAULT_PW" \
    --db_alias="$DB_ALIAS" \
    --db_name="$DB_NAME" \
    --db_host="$DB_HOST" \
    --db_port="$DB_PORT" \
    --ssl_mode="$SSL_MODE" \
    --ssl_ca_chain="$SSL_CA_CHAIN" \
    --ssl_src_cert="$SSL_SRC_CERT" \
    --ssl_src_key="$SSL_SRC_KEY" \
    --vault_policy_token="$DB_VAULT_POLICY_TOKEN"

  exit_on_error "Failed to configure the vault database."

  APP_ROLE_PREFIX="${USER_DB_APPROLE_ALIAS}"
  APP_ROLE_VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/approle-policy.json")

  ./R23_BASE_10_configure_vault_db_approle.sh \
    --db_alias="$DB_ALIAS" \
    --app_role_prefix="$APP_ROLE_PREFIX" \
    --vault_policy_token="$APP_ROLE_VAULT_POLICY_TOKEN"

  exit_on_error "Failed to configure the vault approle."

  print_temp_dirs "${TEMP_KEY}"
  cleanup_temp_dirs "${TEMP_KEY}"
)
