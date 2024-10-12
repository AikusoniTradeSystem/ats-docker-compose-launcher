#!/bin/bash

(
  DB_ALIAS="ats-user-db"
  APP_ROLE_VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' ./credentials/vault/init/approle-policy.json)

  APP_ROLE_PREFIX="${DB_ALIAS}"

  ./25_BASE_00_vault_publish_approle_secret.sh \
    --app_role_prefix="$APP_ROLE_PREFIX" \
    --vault_policy_token="$APP_ROLE_VAULT_POLICY_TOKEN"
)