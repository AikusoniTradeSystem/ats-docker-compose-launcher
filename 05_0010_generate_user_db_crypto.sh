#!/bin/bash

(
  source load_env.sh

  SERVICE_NAME="${USER_DB_SERVICE_NAME}"
  SERVER_CRYPTO_PATH="${USER_DB_SERVER_CRYPTO_PATH}"
  CLIENT_CRYPTO_PATH="${USER_DB_CLIENT_CRYPTO_PATH}"
  CA_CRYPTO_PATH="${USER_DB_CA_CRYPTO_PATH}"
  SERVER_KEY_CNF_FILE_PATH="${USER_DB_SERVER_KEY_CNF_FILE_PATH}"
  SIGNING_SCRIPT_PATH="./05_BASE_root_signing.sh"

  ./05_BASE_generate_service_crypto.sh --service_name="${SERVICE_NAME}" \
                               --server_crypto_path="${SERVER_CRYPTO_PATH}" \
                               --client_crypto_path="${CLIENT_CRYPTO_PATH}" \
                               --ca_crypto_path="${CA_CRYPTO_PATH}" \
                               --server_key_cnf_file_path="${SERVER_KEY_CNF_FILE_PATH}" \
                               --signing_script="${SIGNING_SCRIPT_PATH}"
)