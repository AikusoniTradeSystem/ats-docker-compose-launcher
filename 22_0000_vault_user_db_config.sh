#!/bin/bash

(
  DB_VAULT_ID="vault_acc"
  DB_VAULT_PW="LR4SO@?9X#+vth7e"
  DB_ALIAS="ats-user-db"
  DB_NAME="user_db"
  DB_HOST="ats-user-db"
  DB_PORT="5432"

  SSL_MODE="verify-full"
  SSL_SRC_ROOTCERT="./credentials/certs/ca/${DB_NAME}/ca.crt"
  SSL_SRC_CERT="./credentials/certs/client/${DB_NAME}/client.crt"
  SSL_SRC_KEY="./credentials/certs/client/${DB_NAME}/client.key"
  VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' ./logs/vault/init/database-policy.json)

  ./22_BASE_vault_db_config.sh \
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
    --vault_policy_token="$VAULT_POLICY_TOKEN"
)