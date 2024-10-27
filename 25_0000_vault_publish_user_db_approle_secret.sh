#!/bin/bash

(
  source load_env.sh

  APP_ROLE_ALIAS="${USER_DB_APPROLE_ALIAS}"
  APP_ROLE_VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' ./credentials/vault/init/approle-policy.json)

  APP_ROLE_PREFIX="${APP_ROLE_ALIAS}"

  ./25_BASE_00_vault_publish_approle_secret.sh \
    --app_role_prefix="$APP_ROLE_PREFIX" \
    --vault_policy_token="$APP_ROLE_VAULT_POLICY_TOKEN"
)