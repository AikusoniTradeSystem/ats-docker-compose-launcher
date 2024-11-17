#!/bin/bash

# ==============================================
# Script Name:	Generate Intermediate CA 2
# Description:	This script creates the intermediate CA 2 key and intermediate CA 2 certificate using the custom configuration file signed by the intermediate CA 1.
# ==============================================

(
  # Load configuration file
  source CMN_load_env.sh
  source CMN_load_function.sh

  SIGNING_SCRIPT_CMD="./CMN_ca_signing.sh --ca_key_path=\"${INTER_CA1_PRIVATE_KEY_PATH}\" --ca_cert_path=\"${INTER_CA1_CERT_FILE_PATH}\""

  log d "Create directories if they don't exist for intermediate CA 2..."
  try mkdir -p "${INTER_CA2_CRYPTO_PATH}"
  try mkdir -p "${PUBLIC_CERT_PATH}"

  log i "Call the script to generate intermediate CA 2 key and intermediate CA 2 certificate using the custom configuration file..."
  try ./R03_BASE_generate_intermediate_ca_certs.sh \
    --signing_script_cmd="${SIGNING_SCRIPT_CMD}" \
    --intermediate_ca_private_key_path="${INTER_CA2_PRIVATE_KEY_PATH}" \
    --intermediate_ca_csr_file_path="${INTER_CA2_CSR_FILE_PATH}" \
    --intermediate_ca_cert_path="${INTER_CA2_CERT_FILE_PATH}" \
    --intermediate_ca_cnf_path="${INTER_CA2_CNF_FILE_PATH}" \
    --intermediate_ca_cert_pub_file_path="${INTER_CA2_PUBLIC_CERT_PATH}" \
    --extensions="v3_intermediate_ca"

  try cat "${INTER_CA2_PUBLIC_CERT_PATH}" "${INTER_CA1_PUBLIC_CHAIN_CERT_PATH}" > "${INTER_CA2_PUBLIC_CHAIN_CERT_PATH}"
)