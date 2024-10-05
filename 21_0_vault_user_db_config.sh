#!/bin/sh

(
  export DB_VAULT_ID="vault_acc"
  export DB_VAULT_PW="LR4SO@?9X#+vth7e"
  export DB_ALIAS="ats-user-db"
  export DB_NAME="user_db"
  export DB_HOST="ats-user-db"
  export DB_PORT="5432"
  export SSL_MODE="verify-full"
  export SSL_ROOTCERT="/etc/ssl/certs/ca.crt"
  export SSL_CERT="/etc/ssl/certs/client.crt"
  export SSL_KEY="/etc/ssl/certs/client.key"
  export VAULT_ADDR="http://127.0.0.1:8200"


  docker exec ats-vault vault secrets enable database -address=$VAULT_ADDR
  docker exec ats-vault vault write database/config/${DB_ALIAS} \
      plugin_name=postgresql-database-plugin \
      allowed_roles="${DB_ALIAS}" \
      connection_url="postgresql://${DB_VAULT_ID}:${DB_VAULT_PW}@${DB_HOST}:${DB_PORT}/vault_db?sslmode=${SSL_MODE}&sslrootcert=${SSL_ROOTCERT}&sslcert=${SSL_CERT}&sslkey=${SSL_KEY}" \
      username="${DB_VAULT_ID}" \
      password="${DB_VAULT_PW}"

  docker exec ats-vault vault write database/roles/${DB_ALIAS} \
      db_name=${DB_NAME} \
      creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT, DELETE, UPDATE, INSERT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
      default_ttl="1h" \
      max_ttl="24h"
)