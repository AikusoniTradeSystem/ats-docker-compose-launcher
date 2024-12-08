#!/bin/bash

# ==============================================
# Script Name:  Generate and Sign Client Key
# Description:	This script generates and signs the client key with the Vault PKI.
# ==============================================

if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo -e "Error: This script must be executed from another shell script."
  exit 1
fi

(
  source CMN_load_function.sh
  source CMN_load_adcl_common_function.sh

  TEMP_FILE_KEY="$$"
  TEMP_DIR=$(create_temp_dir "${TEMP_FILE_KEY}")
  VAULT_PKI_TOKEN=""
  ACCESS_CA_CERT_PATH=""
  CLIENT_PKI_ROLE_NAME=""
  CLIENT_COMMON_NAME=""
  CLIENT_ALT_NAMES=""

  PRIVATE_KEY_OUTPUT_PATH=""
  CERTIFICATE_OUTPUT_PATH=""
  CA_CHAIN_OUTPUT_PATH=""

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --vault_pki_token=*) VAULT_PKI_TOKEN="${1#*=}"; shift ;;
      --access_ca_cert_path=*) ACCESS_CA_CERT_PATH="${1#*=}"; shift ;;
      --client_pki_role_name=*) CLIENT_PKI_ROLE_NAME="${1#*=}"; shift ;;
      --client_common_name=*) CLIENT_COMMON_NAME="${1#*=}"; shift ;;
      --client_alt_names=*) CLIENT_ALT_NAMES="${1#*=}"; shift ;;
      --private_key_output_path=*) PRIVATE_KEY_OUTPUT_PATH="${1#*=}"; shift ;;
      --certificate_output_path=*) CERTIFICATE_OUTPUT_PATH="${1#*=}"; shift ;;
      --ca_chain_output_path=*) CA_CHAIN_OUTPUT_PATH="${1#*=}"; shift ;;
      *) echo -e "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  log i "Generate and Sign Client Key"
  log d "VAULT_PKI_TOKEN: ${VAULT_PKI_TOKEN}"
  log d "ACCESS_CA_CERT_PATH: ${ACCESS_CA_CERT_PATH}"
  log d "CLIENT_PKI_ROLE_NAME: ${CLIENT_PKI_ROLE_NAME}"
  log d "CLIENT_COMMON_NAME: ${CLIENT_COMMON_NAME}"
  log d "CLIENT_ALT_NAMES: ${CLIENT_ALT_NAMES}"
  log d "PRIVATE_KEY_OUTPUT_PATH: ${PRIVATE_KEY_OUTPUT_PATH}"
  log d "CERTIFICATE_OUTPUT_PATH: ${CERTIFICATE_OUTPUT_PATH}"
  log d "CA_CHAIN_OUTPUT_PATH: ${CA_CHAIN_OUTPUT_PATH}"

  TEMP_PRIVATE_KEY_PATH="${TEMP_DIR}/private.key"
  TEMP_CERTIFICATE_PATH="${TEMP_DIR}/certificate.crt"
  TEMP_CA_CHAIN_PATH="${TEMP_DIR}/ca-chain.crt"
  TEMP_SIGN_RESPONSE_PATH="${TEMP_DIR}/sign_response.json"

  log d "Getting Vault URL..."
  VAULT_IP_ADDR=$(get_container_ip ${VAULT_CONTAINER_NAME})
  VAULT_URL="${VAULT_URL_SCHEME}://${VAULT_HOST_NAME}:${VAULT_PORT}"
  exit_on_error "Failed to get the Vault URL."
  log d "VAULT_URL: ${VAULT_URL}"

  # Generate PKI Role for current database
  log d "Generating PKI Role for ${CLIENT_PKI_ROLE_NAME}..."
  try curl --cacert "$ACCESS_CA_CERT_PATH" \
       --resolve "${VAULT_HOST_NAME}:${VAULT_PORT}:${VAULT_IP_ADDR}" \
       --header "X-Vault-Token: ${VAULT_PKI_TOKEN}" \
       --request POST \
       --data '{
            "allowed_domain": "'${CLIENT_COMMON_NAME}'",
            "allow_any_name": true,
            "allow_subdomains": true,
            "max_ttl": "720h"
       }' \
       "${VAULT_URL}/v1/pki/roles/${CLIENT_PKI_ROLE_NAME}"

  # Sign the certificate
  log d "Getting the signed certificate and private key from the Vault..."
  try curl --cacert "$ACCESS_CA_CERT_PATH" \
    --resolve "${VAULT_HOST_NAME}:${VAULT_PORT}:${VAULT_IP_ADDR}" \
    --header "X-Vault-Token: ${VAULT_PKI_TOKEN}" \
    --header "Content-Type: application/json" \
    --request POST \
    --data '{
      "common_name": "'${CLIENT_COMMON_NAME}'",
      "alt_names": "'${CLIENT_ALT_NAMES}'"
    }' \
    "${VAULT_URL}/v1/pki/issue/${CLIENT_PKI_ROLE_NAME}" > "$TEMP_SIGN_RESPONSE_PATH"

  log d "Extracting the signed certificate and private key..."
  try jq -r '.data.private_key' "$TEMP_SIGN_RESPONSE_PATH" > "$TEMP_PRIVATE_KEY_PATH"
  try jq -r '.data.certificate' "$TEMP_SIGN_RESPONSE_PATH" > "$TEMP_CERTIFICATE_PATH"
  try jq -r '.data.ca_chain[]' "$TEMP_SIGN_RESPONSE_PATH" > "$TEMP_CA_CHAIN_PATH"

  # Copy the certificate to the output path
  log d "Copying the certificate to the output path..."
  try cp "$TEMP_PRIVATE_KEY_PATH" "$PRIVATE_KEY_OUTPUT_PATH"
  try cp "$TEMP_CERTIFICATE_PATH" "$CERTIFICATE_OUTPUT_PATH"
  try cp "$TEMP_CA_CHAIN_PATH" "$CA_CHAIN_OUTPUT_PATH"

  # cleanup temp dirs
  log i "Cleaning up temp dirs..."
  print_temp_dirs ${TEMP_FILE_KEY}
  cleanup_temp_dirs ${TEMP_FILE_KEY}
)
