#!/bin/sh

(
  VAULT_CONTAINER_NAME="ats-vault"

  # Vault가 이미 초기화되었는지 확인
  docker exec $VAULT_CONTAINER_NAME vault status | grep "Initialized" | grep "true" && exit 0

  mkdir -p ./logs/vault/init

  # Vault 초기화 (10개의 키를 만들고, 최소 3개의 키가 있어야 봉인 해제 가능)
  docker exec $VAULT_CONTAINER_NAME vault operator init -key-shares=10 -key-threshold=3 > ./logs/vault/init/init-keys.txt

  # 생성된 Unseal Key와 Root Token 저장 (최소 3개의 Unseal Key 필요)
  UNSEAL_KEY_1=$(grep 'Unseal Key 1:' ./logs/vault/init/init-keys.txt | awk '{print $4}')
  UNSEAL_KEY_2=$(grep 'Unseal Key 2:' ./logs/vault/init/init-keys.txt | awk '{print $4}')
  UNSEAL_KEY_3=$(grep 'Unseal Key 3:' ./logs/vault/init/init-keys.txt | awk '{print $4}')
  ROOT_TOKEN=$(grep 'Initial Root Token:' ./logs/vault/init/init-keys.txt | awk '{print $4}')

  # Vault Unseal (최소 3개의 Unseal Key를 사용해 봉인 해제)
  docker exec $VAULT_CONTAINER_NAME vault operator unseal $UNSEAL_KEY_1
  docker exec $VAULT_CONTAINER_NAME vault operator unseal $UNSEAL_KEY_2
  docker exec $VAULT_CONTAINER_NAME vault operator unseal $UNSEAL_KEY_3

  # Vault 로그인 (Root Token을 사용해 일시적으로 로그인)
  docker exec $VAULT_CONTAINER_NAME vault login $ROOT_TOKEN

  echo "Vault initialized, unsealed with 3 keys, and logged in with Root Token."

  # 정책 파일 적용 (database-policy.hcl)
  docker exec $VAULT_CONTAINER_NAME vault policy write database-policy /vault/config/database-policy.hcl
  docker exec $VAULT_CONTAINER_NAME vault policy write admin-policy /vault/config/admin-policy.hcl

  # 정책 기반 토큰 생성 (Root Token 대신 사용할 정책 기반 토큰 생성, orphan 옵션은 루트 토큰이 폐기되어도 토큰이 기능하게 만든다.)
  docker exec $VAULT_CONTAINER_NAME vault token create -orphan -policy=database-policy -format=json > ./logs/vault/init/database-policy.json
  docker exec $VAULT_CONTAINER_NAME vault token create -orphan -policy=admin-policy -format=json > ./logs/vault/init/admin-policy.json

  echo "Policy-based tokens created. Token stored in ./logs/vault/init/*-policy.json"

  # Root Token 폐기 (보안 강화)
  docker exec $VAULT_CONTAINER_NAME vault token revoke $ROOT_TOKEN
  echo "Root Token has been revoked for security."

  echo "Vault is now ready to use with policy-based tokens."
)