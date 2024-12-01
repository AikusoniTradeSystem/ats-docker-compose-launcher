#!/bin/bash
set -e

# 템플릿 파일 처리
echo "Processing template files with envsubst..."
for file in /etc/postgresql/templates/*.sql.template; do
    echo "Found: $file"
    [ -e "$file" ] || continue
    envsubst < "$file" > "/docker-entrypoint-initdb.d/$(basename "${file%.template}")"
done
for file in /etc/postgresql/templates/*.conf.template; do
    echo "Found: $file"
    [ -e "$file" ] || continue
    envsubst < "$file" > "/docker-entrypoint-initdb.d/$(basename "${file%.template}")"
done

# 초기화 스크립트 실행 (PostgreSQL 기본 엔트리포인트에 위임)

export SSL_CERT_FILE="${SSL_PATH_IN_CONTAINER}/server.crt"
export SSL_KEY_FILE="${SSL_PATH_IN_CONTAINER}/server.key"
export SSL_CA_FILE="${SSL_PATH_IN_CONTAINER}/ca.crt"

echo "Starting PostgreSQL..."
echo "SSL Cert File: $SSL_CERT_FILE"
echo "SSL Key File: $SSL_KEY_FILE"
echo "SSL CA File: $SSL_CA_FILE"

exec /usr/local/bin/docker-entrypoint.sh postgres \
    -c ssl=on \
    -c ssl_cert_file="$SSL_CERT_FILE" \
    -c ssl_key_file="$SSL_KEY_FILE" \
    -c ssl_ca_file="$SSL_CA_FILE"