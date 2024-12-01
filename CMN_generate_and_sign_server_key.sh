#!/bin/bash

# ==============================================
# Script Name:  Generate and Sign Server Key
# Description:	This script generates and signs the server key with the Vault PKI.
# ==============================================

if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo -e "Error: This script must be executed from another shell script."
  exit 1
fi

(
  source CMN_load_function.sh

  TEMP_FILE_KEY="$$"
  TEMP_DIR=$(create_temp_dir "${TEMP_FILE_KEY}")
  VAULT_PKI_TOKEN=""
  ACCESS_CA_CERT_PATH=""
  BARE_HOST_NAME=""
  SERVER_CONTAINER_NAME=""
  SERVER_HOST_NAME=""
  SERVER_PKI_ROLE_NAME=""

  PRIVATE_KEY_OUTPUT_PATH=""
  CSR_OUTPUT_PATH=""
  CERTIFICATE_OUTPUT_PATH=""
  CA_CHAIN_OUTPUT_PATH=""

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --vault_pki_token=*) VAULT_PKI_TOKEN="${1#*=}"; shift ;;
      --access_ca_cert_path=*) ACCESS_CA_CERT_PATH="${1#*=}"; shift ;;
      --bare_host_name=*) BARE_HOST_NAME="${1#*=}"; shift ;;
      --server_container_name=*) SERVER_CONTAINER_NAME="${1#*=}"; shift ;;
      --server_host_name=*) SERVER_HOST_NAME="${1#*=}"; shift ;;
      --server_pki_role_name=*) SERVER_PKI_ROLE_NAME="${1#*=}"; shift ;;
      --private_key_output_path=*) PRIVATE_KEY_OUTPUT_PATH="${1#*=}"; shift ;;
      --csr_output_path=*) CSR_OUTPUT_PATH="${1#*=}"; shift ;;
      --certificate_output_path=*) CERTIFICATE_OUTPUT_PATH="${1#*=}"; shift ;;
      --ca_chain_output_path=*) CA_CHAIN_OUTPUT_PATH="${1#*=}"; shift ;;
      *) echo -e "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  log i "Generate and Sign Server Key"
  log d "VAULT_PKI_TOKEN: ${VAULT_PKI_TOKEN}"
  log d "ACCESS_CA_CERT_PATH: ${ACCESS_CA_CERT_PATH}"
  log d "BARE_HOST_NAME: ${BARE_HOST_NAME}"
  log d "SERVER_CONTAINER_NAME: ${SERVER_CONTAINER_NAME}"
  log d "SERVER_HOST_NAME: ${SERVER_HOST_NAME}"
  log d "SERVER_PKI_ROLE_NAME: ${SERVER_PKI_ROLE_NAME}"
  log d "PRIVATE_KEY_OUTPUT_PATH: ${PRIVATE_KEY_OUTPUT_PATH}"
  log d "CSR_OUTPUT_PATH: ${CSR_OUTPUT_PATH}"
  log d "CERTIFICATE_OUTPUT_PATH: ${CERTIFICATE_OUTPUT_PATH}"

  TEMP_PRIVATE_KEY_PATH="${TEMP_DIR}/private.key"
  TEMP_CSR_PATH="${TEMP_DIR}/request.csr"
  TEMP_CERTIFICATE_PATH="${TEMP_DIR}/certificate.crt"
  TEMP_CA_CHAIN_PATH="${TEMP_DIR}/ca_chain.crt"
  TEMP_SIGN_RESPONSE_PATH="${TEMP_DIR}/sign_response.json"

  # Generate PKI Role for current database
  log d "Generating PKI Role for ${SERVER_PKI_ROLE_NAME}..."
  try curl --cacert "$ACCESS_CA_CERT_PATH" \
       --header "X-Vault-Token: ${VAULT_PKI_TOKEN}" \
       --request POST \
       --data '{
            "allowed_domains": "'${BARE_HOST_NAME}'",
            "allow_subdomains": true,
            "allow_ip_sans": true,
            "max_ttl": "720h"
       }' \
       "https://localhost:8200/v1/pki/roles/${SERVER_PKI_ROLE_NAME}"

  # Generate the private key
  log d "Generating private key... ${TEMP_PRIVATE_KEY_PATH}"
  openssl genrsa -out "$TEMP_PRIVATE_KEY_PATH" 4096
  exit_on_error "Failed to generate private key."

  # Generate the request csr
  log d "Generating request csr... ${TEMP_CSR_PATH}"
  openssl req -new -key "$TEMP_PRIVATE_KEY_PATH" -out "$TEMP_CSR_PATH" \
      -subj "/CN=${SERVER_HOST_NAME}" \
      -reqexts SAN \
      -config <(cat <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = SAN
prompt = no

[req_distinguished_name]
CN =${SERVER_HOST_NAME}

[SAN]
subjectAltName = DNS.1:${SERVER_HOST_NAME}, DNS.2:localhost, IP:127.0.0.1
EOF
)
  exit_on_error "Failed to generate request csr."

  # Sign the certificate
  log d "Signing the certificate... ${TEMP_CERTIFICATE_PATH}"
  try curl --cacert "$ACCESS_CA_CERT_PATH" \
    --header "X-Vault-Token: ${VAULT_PKI_TOKEN}" \
    --header "Content-Type: application/json" \
    --request POST \
    --data "$(jq -n --arg csr "$(cat $TEMP_CSR_PATH)" '{csr: $csr}')" \
    "https://localhost:8200/v1/pki/sign/${SERVER_PKI_ROLE_NAME}" > "$TEMP_SIGN_RESPONSE_PATH"

  try jq -r '.data.certificate' "$TEMP_SIGN_RESPONSE_PATH" > "$TEMP_CERTIFICATE_PATH"
  try jq -r '.data.ca_chain[]' "$TEMP_SIGN_RESPONSE_PATH" > "$TEMP_CA_CHAIN_PATH"

  # Copy the certificate to the output path
  log d "Copying the certificate to the output path..."
  try cp "$TEMP_PRIVATE_KEY_PATH" "$PRIVATE_KEY_OUTPUT_PATH"
  try cp "$TEMP_CSR_PATH" "$CSR_OUTPUT_PATH"
  try cp "$TEMP_CERTIFICATE_PATH" "$CERTIFICATE_OUTPUT_PATH"
  try cp "$TEMP_CA_CHAIN_PATH" "$CA_CHAIN_OUTPUT_PATH"

  # cleanup temp dirs
  log i "Cleaning up temp dirs..."
  print_temp_dirs ${TEMP_FILE_KEY}
  cleanup_temp_dirs ${TEMP_FILE_KEY}
)
