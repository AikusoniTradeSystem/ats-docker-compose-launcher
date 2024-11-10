#!/bin/bash

# ==============================================
# Script Name:	Enable Vault Secrets Engine - PKI
# Description:	This script enables the PKI secrets engine in Vault.
# ==============================================
# Reference:
# HashiCorp Vault PKI Secrets Engine: Quick Start - Intermediate CA Setup
# ( https://developer.hashicorp.com/vault/docs/secrets/pki/quick-start-intermediate-ca )
# ==============================================

(
  source load_env.sh
  source load_function.sh

  ENGINE_TYPE="secrets"
  ENGINE_NAME="pki"
  VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/admin-policy.json")

  ./R12_BASE_00_enable_engine.sh \
    --engine_type="$ENGINE_TYPE" \
    --engine_name="$ENGINE_NAME" \
    --vault_policy_token="$VAULT_POLICY_TOKEN"

  exit_on_error "Failed to enable Vault Auth Engine - AppRole."
)