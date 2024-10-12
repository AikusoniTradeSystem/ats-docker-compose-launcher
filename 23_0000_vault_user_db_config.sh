#!/bin/bash

(
  DB_VAULT_ID="vault_access"
  DB_VAULT_PW="LR4SO@?9X#+vth7e"
  DB_ALIAS="ats-user-db"
  DB_NAME="user_db"
  DB_HOST="ats-user-db"
  DB_PORT="5432"

  SSL_MODE="verify-full"
  SSL_SRC_ROOTCERT="./credentials/certs/ca/${DB_NAME}/ca.crt"
  SSL_SRC_CERT="./credentials/certs/client/${DB_NAME}/client.crt"
  SSL_SRC_KEY="./credentials/certs/client/${DB_NAME}/client.key"
  DB_VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' ./credentials/vault/init/database-policy.json)

  ./23_BASE_00_vault_db_config.sh \
    --db_vault_id="$DB_VAULT_ID" \
    --db_vault_pw="$DB_VAULT_PW" \
    --db_alias="$DB_ALIAS" \
    --db_name="$DB_NAME" \
    --db_host="$DB_HOST" \
    --db_port="$DB_PORT" \
    --ssl_mode="$SSL_MODE" \
    --ssl_src_rootcert="$SSL_SRC_ROOTCERT" \
    --ssl_src_cert="$SSL_SRC_CERT" \
    --ssl_src_key="$SSL_SRC_KEY" \
    --vault_policy_token="$DB_VAULT_POLICY_TOKEN"

  EXIT_CODE=$?

  # exit 코드 출력
  echo "The exit code of 23_BASE_00_vault_db_config.sh is: $EXIT_CODE"

  # exit 코드에 따른 작업
  if [ $EXIT_CODE -ne 0 ]; then
    echo "23_BASE_00_vault_db_config.sh script failed with exit code $EXIT_CODE."
    exit 1
  fi

  APP_ROLE_PREFIX="${DB_ALIAS}"
  APP_ROLE_VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' ./credentials/vault/init/approle-policy.json)

  ./23_BASE_10_vault_db_approle_config.sh \
    --app_role_prefix="$APP_ROLE_PREFIX" \
    --vault_policy_token="$APP_ROLE_VAULT_POLICY_TOKEN"
)