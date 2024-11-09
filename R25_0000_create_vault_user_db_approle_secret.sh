#!/bin/bash

# ==============================================
# Script Name:  Create Vault AppRole Secret for User Database
# Description:  This script creates the Vault AppRole secret for the user database.
# ==============================================

(
  source load_env.sh
  source load_function.sh

  APP_ROLE_ALIAS="${USER_DB_APPROLE_ALIAS}"
  APP_ROLE_VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' ./credentials/vault/init/approle-policy.json)

  APP_ROLE_PREFIX="${APP_ROLE_ALIAS}"

  ./R25_BASE_00_vault_publish_approle_secret.sh \
    --app_role_prefix="$APP_ROLE_PREFIX" \
    --vault_policy_token="$APP_ROLE_VAULT_POLICY_TOKEN"
)