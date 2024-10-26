#!/bin/bash

(
  source common.sh

  SERVICE_NAME="${VAULT_SERVICE_NAME}"
  SERVER_CRYPTO_PATH="${VAULT_SERVER_CRYPTO_PATH}"
  CLIENT_CRYPTO_PATH="${VAULT_CLIENT_CRYPTO_PATH}"
  CA_CRYPTO_PATH="${VAULT_CA_CRYPTO_PATH}"
  SERVER_KEY_CNF_FILE_PATH="${VAULT_SERVER_KEY_CNF_FILE_PATH}"
  SIGNING_SCRIPT_PATH="./05_BASE_root_signing.sh"

  ./05_BASE_generate_service_crypto.sh --service_name="${SERVICE_NAME}" \
                  --server_crypto_path="${SERVER_CRYPTO_PATH}" \
                  --client_crypto_path="${CLIENT_CRYPTO_PATH}" \
                  --ca_crypto_path="${CA_CRYPTO_PATH}" \
                  --server_key_cnf_file_path="${SERVER_KEY_CNF_FILE_PATH}" \
                  --signing_script="${SIGNING_SCRIPT_PATH}"
)