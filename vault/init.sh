#!/bin/sh

# Vault가 이미 초기화되었는지 확인
vault status | grep "Initialized" | grep "true" && exit 0

# Vault 초기화
vault operator init -key-shares=1 -key-threshold=1 > /vault/logs/init-keys.txt

# 생성된 Unseal Key와 Root Token 저장
UNSEAL_KEY=$(grep 'Unseal Key 1:' /vault/logs/init-keys.txt | awk '{print $4}')
ROOT_TOKEN=$(grep 'Initial Root Token:' /vault/logs/init-keys.txt | awk '{print $4}')

# Vault Unseal
vault operator unseal $UNSEAL_KEY

# Vault 로그인
vault login $ROOT_TOKEN

echo "Vault initialized and unsealed"
