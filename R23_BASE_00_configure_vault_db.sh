#!/bin/bash

# ==============================================
# Script Name:	Base Configure Vault Database Script
# Description:	This script configures the database connection in Vault.
# Information:	This script is executed by other scripts to configure the database connection in Vault.
# ==============================================

if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo -e "Error: This script must be executed from another shell script."
  exit 1
fi

(
  source CMN_load_function.sh

  DB_VAULT_ID=""
  DB_VAULT_PW=""
  DB_ALIAS=""
  DB_NAME=""
  DB_HOST=""
  DB_PORT=""
  SSL_MODE=""
  SSL_SRC_ROOTCERT=""
  SSL_SRC_CERT=""
  SSL_SRC_KEY=""
  VAULT_POLICY_TOKEN=""

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --db_vault_id=*) DB_VAULT_ID="${1#*=}"; shift ;;
      --db_vault_pw=*) DB_VAULT_PW="${1#*=}"; shift ;;
      --db_alias=*) DB_ALIAS="${1#*=}"; shift ;;
      --db_name=*) DB_NAME="${1#*=}"; shift ;;
      --db_host=*) DB_HOST="${1#*=}"; shift ;;
      --db_port=*) DB_PORT="${1#*=}"; shift ;;
      --ssl_mode=*) SSL_MODE="${1#*=}"; shift ;;
      --ssl_src_rootcert=*) SSL_SRC_ROOTCERT="${1#*=}"; shift ;;
      --ssl_src_cert=*) SSL_SRC_CERT="${1#*=}"; shift ;;
      --ssl_src_key=*) SSL_SRC_KEY="${1#*=}"; shift ;;
      --vault_policy_token=*) VAULT_POLICY_TOKEN="${1#*=}"; shift ;;
      *) echo -e "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  # 경로 변수 설정
  SSL_DEST_DIR="/etc/ssl/certs/client/${DB_NAME}"

  echo -e "DB_VAULT_ID: $DB_VAULT_ID"
  echo -e "DB_VAULT_PW: $DB_VAULT_PW"
  echo -e "DB_ALIAS: $DB_ALIAS"
  echo -e "DB_NAME: $DB_NAME"
  echo -e "DB_HOST: $DB_HOST"
  echo -e "DB_PORT: $DB_PORT"
  echo -e "SSL_MODE: $SSL_MODE"
  echo -e "SSL_SRC_ROOTCERT: $SSL_SRC_ROOTCERT"
  echo -e "SSL_SRC_CERT: $SSL_SRC_CERT"
  echo -e "SSL_SRC_KEY: $SSL_SRC_KEY"
  echo -e "SSL_DEST_DIR: $SSL_DEST_DIR"
#  echo -e "VAULT_POLICY_TOKEN: $VAULT_POLICY_TOKEN"

  # 인증서 파일을 /etc/ssl/certs/client/${DB_NAME} 디렉토리에 복사
  echo -e "Copying SSL certificates to the Vault container..."
  docker exec ${VAULT_CONTAINER_NAME} mkdir -p ${SSL_DEST_DIR}
  exit_on_error "Failed to create directory for SSL certificates."
  docker cp "$SSL_SRC_ROOTCERT" ${VAULT_CONTAINER_NAME}:${SSL_DEST_DIR}/ca.crt
  exit_on_error "Failed to copy root certificate."
  docker cp "$SSL_SRC_CERT" ${VAULT_CONTAINER_NAME}:${SSL_DEST_DIR}/client.crt
  exit_on_error "Failed to copy client certificate."
  docker cp "$SSL_SRC_KEY" ${VAULT_CONTAINER_NAME}:${SSL_DEST_DIR}/client.key
  exit_on_error "Failed to copy client key."

  # 복사한 파일의 권한 설정 (Vault가 접근할 수 있도록)
  echo -e "Setting ownership and permissions for SSL certificates..."
  docker exec ${VAULT_CONTAINER_NAME} chown vault:vault ${SSL_DEST_DIR}/ca.crt ${SSL_DEST_DIR}/client.crt ${SSL_DEST_DIR}/client.key
  exit_on_error "Failed to change ownership of SSL certificates."
  docker exec ${VAULT_CONTAINER_NAME} chmod 600 ${SSL_DEST_DIR}/client.key
  exit_on_error "Failed to change permissions of SSL certificates."
  docker exec ${VAULT_CONTAINER_NAME} chmod 600 ${SSL_DEST_DIR}/ca.crt
  exit_on_error "Failed to change permissions of SSL certificates."
  docker exec ${VAULT_CONTAINER_NAME} chmod 600 ${SSL_DEST_DIR}/client.crt
  exit_on_error "Failed to change permissions of SSL certificates."

  # Vault에 데이터베이스 연결 설정
  docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write database/config/${DB_ALIAS} \
      plugin_name=postgresql-database-plugin \
      allowed_roles="${DB_ALIAS}" \
      connection_url="postgresql://{{username}}:{{password}}@${DB_HOST}:${DB_PORT}/${DB_NAME}?sslmode=${SSL_MODE}&sslrootcert=${SSL_DEST_DIR}/ca.crt&sslcert=${SSL_DEST_DIR}/client.crt&sslkey=${SSL_DEST_DIR}/client.key" \
      username="${DB_VAULT_ID}" \
      password="${DB_VAULT_PW}"
  exit_on_error "Failed to configure database connection."

  docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write "database/roles/${DB_ALIAS}" \
      db_name="${DB_NAME}" \
      creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT, DELETE, UPDATE, INSERT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
      default_ttl="1h" \
      max_ttl="24h"
  exit_on_error "Failed to configure database role."
)
