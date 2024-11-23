#!/bin/bash

# ==============================================
# Script Name:  Install Vault Intermediate CA
# Description:  This script installs the Intermediate CA into the Vault.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  TEMP_FILE_KEY="$$"
  INTERMEDIATE_CA_TEMP_DIR=$(create_temp_dir "${TEMP_FILE_KEY}")
  INTERMEDIATE_CA_CSR_PATH="${INTERMEDIATE_CA_TEMP_DIR}/intermediate.csr"
  INTERMEDIATE_CA_CNF_PATH="${VAULT_INTERMEDIATE_CA_CNF_FILE_PATH}"
  INTERMEDIATE_CA_CRT_PATH="${INTERMEDIATE_CA_TEMP_DIR}/intermediate.crt"
  INTERMEDIATE_CA_CHAIN_CRT_PATH="${INTERMEDIATE_CA_TEMP_DIR}/intermediate_chain.crt"
  INTERMEDIATE_CA_CRT_PATH_IN_CONTAINER="/tmp/intermediate.crt"
  print_temp_dirs ${TEMP_FILE_KEY}

  echo "INTERMEDIATE_CA_TEMP_DIR: ${INTERMEDIATE_CA_TEMP_DIR}"
  echo "INTERMEDIATE_CA_CSR_PATH: ${INTERMEDIATE_CA_CSR_PATH}"
  echo "INTERMEDIATE_CA_CRT_PATH: ${INTERMEDIATE_CA_CRT_PATH}"

  TTL="8760h"
  PKI_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/pki-policy.json")

  try docker exec -e VAULT_TOKEN="${PKI_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write pki/config/urls \
      issuing_certificates="${VAULT_ADDR}/v1/pki/ca" \
      crl_distribution_points="${VAULT_ADDR}/v1/pki/crl" \
      ocsp_servers="${VAULT_ADDR}/v1/pki/ocsp"

  try docker exec -e VAULT_TOKEN="${PKI_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write -format=json pki/intermediate/generate/internal \
                                                                                     common_name="ats.internal" \
                                                                                     ttl="${TTL}" | jq -r '.data.csr' > "${INTERMEDIATE_CA_CSR_PATH}"

  try ./CMN_ca_signing.sh --ca_key_path="${INTER_CA2_PRIVATE_KEY_PATH}" --ca_cert_path="${INTER_CA2_CERT_FILE_PATH}" \
                          --csr="${INTERMEDIATE_CA_CSR_PATH}" --output="${INTERMEDIATE_CA_CRT_PATH}" \
                          --conf="${INTERMEDIATE_CA_CNF_PATH}" --extensions="v3_intermediate_ca"

  try cat "${INTERMEDIATE_CA_CRT_PATH}" "${INTER_CA2_CERT_FILE_PATH}" > "${INTERMEDIATE_CA_CHAIN_CRT_PATH}"
  log d "Intermediate and root certificates combined into ${INTERMEDIATE_CA_CHAIN_CRT_PATH}"

  try docker cp "${INTERMEDIATE_CA_CHAIN_CRT_PATH}" ${VAULT_CONTAINER_NAME}:${INTERMEDIATE_CA_CRT_PATH_IN_CONTAINER}
  try docker exec -e VAULT_TOKEN="${PKI_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write pki/intermediate/set-signed \
      certificate=@"${INTERMEDIATE_CA_CRT_PATH_IN_CONTAINER}"

  print_temp_dirs ${TEMP_FILE_KEY}
  cleanup_temp_dirs ${TEMP_FILE_KEY}
)