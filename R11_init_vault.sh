#!/bin/bash

# ==============================================
# Script Name:	Initialize Vault
# Description:	This script initializes the Vault server, unseals it, and creates policy-based tokens.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  # Vault가 이미 초기화되었는지 확인
  try docker exec "$VAULT_CONTAINER_NAME" vault status | grep "Initialized" | grep "true" && exit 0

  try mkdir -p "${VAULT_CREDENTIAL_INIT_PATH}"

  # Vault 초기화 (10개의 키를 만들고, 최소 3개의 키가 있어야 봉인 해제 가능)
  try docker exec "$VAULT_CONTAINER_NAME" vault operator init -key-shares=${VAULT_KEY_SHARES} -key-threshold=${VAULT_KEY_THRESHOLD} > "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt"

  # 생성된 Root Token 출력
  ROOT_TOKEN=$(grep 'Initial Root Token:' "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')

  # 루프를 사용하여 모든 Unseal 키를 저장 및 출력
  for i in $(seq 1 $VAULT_KEY_SHARES); do
    UNSEAL_KEY=$(grep "Unseal Key $i:" "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')
    log i "Unseal Key $i: $UNSEAL_KEY"
  done

  # Vault Unseal (최소 $VAULT_KEY_THRESHOLD개의 Unseal Key를 사용해 봉인 해제)
  for i in $(seq 1 $VAULT_KEY_THRESHOLD); do
    UNSEAL_KEY=$(grep "Unseal Key $i:" "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')
    try docker exec $VAULT_CONTAINER_NAME vault operator unseal "$UNSEAL_KEY"
  done


  # Vault 로그인 (Root Token을 사용해 일시적으로 로그인)
  docker exec $VAULT_CONTAINER_NAME vault login "$ROOT_TOKEN"
  exit_on_error "Failed to login to Vault." 2

  log s "Vault initialized, unsealed with 3 keys, and logged in with Root Token."

  # 정책 이름 배열
  policies=("approle-policy" "database-policy" "pki-policy" "admin-policy")

  # 정책 파일 적용 및 정책 기반 토큰 생성
  for policy in "${policies[@]}"; do
    # 정책 파일 적용
    docker exec "$VAULT_CONTAINER_NAME" vault policy write "$policy" "/vault/config/$policy.hcl"
    exit_on_error "Failed to apply policy $policy" 3

    # 정책 기반 토큰 생성
    docker exec "$VAULT_CONTAINER_NAME" vault token create -orphan -policy="$policy" -format=json > "$VAULT_CREDENTIAL_INIT_PATH/$policy.json"
    exit_on_error "Failed to create token for policy $policy" 4
  done

  log s "Policy-based tokens created. Token stored in ${VAULT_CREDENTIAL_INIT_PATH}/*-policy.json"

  # Root Token 폐기 (보안 강화)
  docker exec $VAULT_CONTAINER_NAME vault token revoke "$ROOT_TOKEN"
  exit_on_error "Failed to revoke Root Token." 5
  log i "Root Token has been revoked for security."

  log s "Vault is now ready to use with policy-based tokens."

  log imp "[IMPORTANT] Unseal keys have been generated."
  log imp "Please manually distribute these keys among administrators and securely store them."
  # 루프를 사용하여 모든 Unseal 키 출력
  for i in $(seq 1 $VAULT_KEY_SHARES); do
    UNSEAL_KEY=$(grep "Unseal Key $i:" "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')
    log imp "Unseal Key $i: $UNSEAL_KEY"
  done
  log s "Once the keys are securely distributed, manually delete the init-keys.txt file for security purposes."
)