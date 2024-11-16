#!/bin/bash

# ==============================================
# Script Name:  Install Vault Intermediate CA
# Description:  This script installs the Intermediate CA into the Vault.
# ==============================================

(
  source load_env.sh
  source load_function.sh

  tempkey="$$"
  INTERMEDIATE_CA_TEMP_DIR=$(create_temp_dir "${tempkey}")
  INTERMEDIATE_CA_CSR_PATH="${INTERMEDIATE_CA_TEMP_DIR}/intermediate.csr"
  INTERMEDIATE_CA_CNF_PATH="${INTERMEDIATE_CA_TEMP_DIR}/intermediate.cnf"
  INTERMEDIATE_CA_CRT_PATH="${INTERMEDIATE_CA_TEMP_DIR}/intermediate.crt"
  INTERMEDIATE_CA_CRT_PATH_IN_CONTAINER="/tmp/intermediate.crt"
  print_temp_dirs ${tempkey}

  echo "INTERMEDIATE_CA_TEMP_DIR: ${INTERMEDIATE_CA_TEMP_DIR}"
  echo "INTERMEDIATE_CA_CSR_PATH: ${INTERMEDIATE_CA_CSR_PATH}"
  echo "INTERMEDIATE_CA_CRT_PATH: ${INTERMEDIATE_CA_CRT_PATH}"

  TTL="8760h"
  PKI_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/pki-policy.json")

  try docker exec -e VAULT_TOKEN="${PKI_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write -format=json pki/intermediate/generate/internal \
                                                                                     common_name="ats-vault Intermediate CA" \
                                                                                     ttl="${TTL}" | jq -r '.data.csr' > "${INTERMEDIATE_CA_CSR_PATH}"

  # SAN 설정을 임시 파일로 저장
  try bash -c "cat <<'EOF' > '$INTERMEDIATE_CA_CNF_PATH'
[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_intermediate_ca
prompt = no

[ req_distinguished_name ]
C  = KR
ST = Gyeonggido
L  = Pyeongtaek
O  = AikusoniTradeSystem
OU = Security Team
CN = Aikusoni Root CA

[ v3_intermediate_ca ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints       = critical, CA:true, pathlen:0
keyUsage               = critical, digitalSignature, cRLSign, keyCertSign
EOF"

  cat $INTERMEDIATE_CA_CNF_PATH

  try ./CMN_ca_signing.sh --ca_key_path="${INTER_CA2_PRIVATE_KEY_PATH}" --ca_cert_path="${INTER_CA2_CERT_FILE_PATH}" \
                          --csr="${INTERMEDIATE_CA_CSR_PATH}" --output="${INTERMEDIATE_CA_CRT_PATH}" \
                          --conf="${INTERMEDIATE_CA_CNF_PATH}" --extensions="v3_intermediate_ca"

  try docker cp "${INTERMEDIATE_CA_CRT_PATH}" ${VAULT_CONTAINER_NAME}:${INTERMEDIATE_CA_CRT_PATH_IN_CONTAINER}
  try docker exec -e VAULT_TOKEN="${PKI_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write pki/intermediate/set-signed \
      certificate=@"${INTERMEDIATE_CA_CRT_PATH_IN_CONTAINER}"

  print_temp_dirs ${tempkey}
  cleanup_temp_dirs ${tempkey}
)