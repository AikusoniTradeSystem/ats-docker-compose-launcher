#!/bin/bash

# ==============================================
# Script Name:	Enable Vault Secrets Engine - Database
# Description:	This script enables the database secrets engine in Vault.
# ==============================================
# Reference:
# HashiCorp Vault Database Secrets Engine
# ( https://developer.hashicorp.com/vault/docs/secrets/databases )
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  ENGINE_TYPE="secrets"
  ENGINE_NAME="database"
  VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/admin-policy.json")

  ./R12_BASE_00_enable_engine.sh \
    --engine_type="$ENGINE_TYPE" \
    --engine_name="$ENGINE_NAME" \
    --vault_policy_token="$VAULT_POLICY_TOKEN"

  exit_on_error "Failed to enable Vault Secrets Engine - Database."
)