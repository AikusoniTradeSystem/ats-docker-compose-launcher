#!/bin/sh

# /vault/data의 소유권을 vault 사용자로 변경
chown -R vault:vault /vault/data

# Vault 서버 시작
exec vault server -config=/vault/config/vault-config.hcl
