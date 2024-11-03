#!/bin/bash

(
  # Load configuration file
  source load_env.sh
  source load_function.sh

  SIGNING_SCRIPT_CMD="./CMN_ca_signing.sh --ca_key_path=\"${ROOT_CA_PRIVATE_KEY_PATH}\" --ca_cert_path=\"${ROOT_CA_CERT_FILE_PATH}\""

  log d "Create directories if they don't exist for intermediate CA 1..."
  mkdir -p "${INTER_CA1_CRYPTO_PATH}"
  mkdir -p "${PUBLIC_CERT_PATH}"

  log i "Call the script to generate intermediate CA 1 key and intermediate CA 1 certificate using the custom configuration file..."
  ./03_BASE_generate_intermediate_ca_certs.sh \
    --signing_script_cmd="${SIGNING_SCRIPT_CMD}" \
    --intermediate_ca_private_key_path="${INTER_CA1_PRIVATE_KEY_PATH}" \
    --intermediate_ca_csr_file_path="${INTER_CA1_CSR_FILE_PATH}" \
    --intermediate_ca_cert_path="${INTER_CA1_CERT_FILE_PATH}" \
    --intermediate_ca_cnf_path="${INTER_CA1_CNF_FILE_PATH}" \
    --intermediate_ca_cert_pub_file_path="${INTER_CA1_PUBLIC_CERT_PATH}" \
    --extensions="v3_intermediate_ca"
)