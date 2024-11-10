#!/bin/bash

# ==============================================
# Script Name:  Install Vault Intermediate CA
# Description:  This script installs the Intermediate CA into the Vault.
# ==============================================

(
  source load_env.sh
  source load_function.sh

  TTL="8760h" # 1년
  PKI_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/pki-policy.json")

  try docker exec -e VAULT_TOKEN="${PKI_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write pki/intermediate/generate/internal \
                                                                                     common_name="ats-vault Intermediate CA" \
                                                                                     ttl="${TTL}" > intermediate_ca.csr

  # TODO signing the intermediate CA certificate with the root CA certificate

  # TODO importing the signed intermediate CA certificate into the Vault
)