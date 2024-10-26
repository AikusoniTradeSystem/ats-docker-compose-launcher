#!/bin/bash

(
  source common.sh

  DB_VAULT_ID="${USER_DB_VAULT_ID}"
  DB_VAULT_PW="${USER_DB_VAULT_PW}"
  DB_ALIAS="${USER_DB_APPROLE_ALIAS}"
  DB_NAME="${USER_DB_SERVICE_NAME}"
  DB_HOST="${USER_DB_HOST_NAME}"
  DB_PORT="${USER_DB_PORT}"

  SSL_MODE="verify-full"
  SSL_SRC_ROOTCERT="${USER_DB_CA_CRYPTO_PATH}/ca_self.crt"
  SSL_SRC_CERT="${USER_DB_CLIENT_CRYPTO_PATH}/client.crt"
  SSL_SRC_KEY="${USER_DB_CLIENT_CRYPTO_PATH}/client.key"
  DB_VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/database-policy.json")

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
  echo -e "The exit code of 23_BASE_00_vault_db_config.sh is: $EXIT_CODE"

  # exit 코드에 따른 작업
  if [ $EXIT_CODE -ne 0 ]; then
    echo -e "23_BASE_00_vault_db_config.sh script failed with exit code $EXIT_CODE."
    exit 1
  fi

  APP_ROLE_PREFIX="${USER_DB_APPROLE_ALIAS}"
  APP_ROLE_VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/approle-policy.json")

  ./23_BASE_10_vault_db_approle_config.sh \
    --db_alias="$DB_ALIAS" \
    --app_role_prefix="$APP_ROLE_PREFIX" \
    --vault_policy_token="$APP_ROLE_VAULT_POLICY_TOKEN"
)