#!/bin/sh

# /vault/data의 소유권을 vault 사용자로 변경
chown -R vault:vault /vault/data

cp /vault/init-keys/server.key /etc/ssl/private/server.key
cp /vault/init-keys/server.crt /etc/ssl/certs/server.crt
cp /vault/init-keys/full_chain.crt /etc/ssl/certs/full_chain.crt

# Vault 서버 시작
exec vault server -config=/vault/config/vault-config.hcl
