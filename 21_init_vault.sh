#!/bin/bash

(
  source load_env.sh

  # Vault가 이미 초기화되었는지 확인
  docker exec "$VAULT_CONTAINER_NAME" vault status | grep "Initialized" | grep "true" && exit 0

  mkdir -p "${VAULT_CREDENTIAL_INIT_PATH}"

  # Vault 초기화 (10개의 키를 만들고, 최소 3개의 키가 있어야 봉인 해제 가능)
  if ! docker exec "$VAULT_CONTAINER_NAME" vault operator init -key-shares=${VAULT_KEY_SHARES} -key-threshold=${VAULT_KEY_THRESHOLD} > "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt"; then
    echo -e "${SHELL_TEXT_ERROR}Failed to initialize Vault.${SHELL_TEXT_RESET}"
    exit 1
  fi

  # 생성된 Root Token 출력
  ROOT_TOKEN=$(grep 'Initial Root Token:' "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')

  # 루프를 사용하여 모든 Unseal 키를 저장 및 출력
  for i in $(seq 1 $VAULT_KEY_SHARES); do
    UNSEAL_KEY=$(grep "Unseal Key $i:" "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')
    echo -e "${SHELL_TEXT_SUCCESS}Unseal Key $i: $UNSEAL_KEY${SHELL_TEXT_RESET}"
  done

  # Vault Unseal (최소 $VAULT_KEY_THRESHOLD개의 Unseal Key를 사용해 봉인 해제)
  for i in $(seq 1 $VAULT_KEY_THRESHOLD); do
    UNSEAL_KEY=$(grep "Unseal Key $i:" "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')
    docker exec $VAULT_CONTAINER_NAME vault operator unseal "$UNSEAL_KEY"
  done


  # Vault 로그인 (Root Token을 사용해 일시적으로 로그인)
  docker exec $VAULT_CONTAINER_NAME vault login "$ROOT_TOKEN"
  if [ $? -ne 0 ]; then
    echo -e "${SHELL_TEXT_ERROR}Failed to login to Vault.${SHELL_TEXT_RESET}"
    exit 2
  fi

  echo -e "Vault initialized, unsealed with 3 keys, and logged in with Root Token."

  # 정책 이름 배열
  policies=("approle-policy" "database-policy" "admin-policy")

  # 정책 파일 적용 및 정책 기반 토큰 생성
  for policy in "${policies[@]}"; do
    # 정책 파일 적용
    if ! docker exec "$VAULT_CONTAINER_NAME" vault policy write "$policy" "/vault/config/$policy.hcl"; then
      echo "Error: Failed to apply policy $policy"
      exit 1
    fi

    # 정책 기반 토큰 생성
    if ! docker exec "$VAULT_CONTAINER_NAME" vault token create -orphan -policy="$policy" -format=json > "$VAULT_CREDENTIAL_INIT_PATH/$policy.json"; then
      echo "Error: Failed to create token for policy $policy"
      exit 1
    fi
  done

  echo -e "Policy-based tokens created. Token stored in ${VAULT_CREDENTIAL_INIT_PATH}/*-policy.json"

  # Root Token 폐기 (보안 강화)
  docker exec $VAULT_CONTAINER_NAME vault token revoke "$ROOT_TOKEN"
  echo -e "Root Token has been revoked for security."

  echo -e "Vault is now ready to use with policy-based tokens."

  echo -e "${SHELL_TEXT_BOLD_RED}[IMPORTANT] Unseal keys have been generated.${SHELL_TEXT_RESET}"
  echo -e "${SHELL_TEXT_INFO}Please manually distribute these keys among administrators and securely store them.${SHELL_TEXT_RESET}"
  # 루프를 사용하여 모든 Unseal 키 출력
  for i in $(seq 1 $VAULT_KEY_SHARES); do
    UNSEAL_KEY=$(grep "Unseal Key $i:" "${VAULT_CREDENTIAL_INIT_PATH}/init-keys.txt" | awk '{print $4}')
    echo -e "${SHELL_TEXT_SUCCESS}Unseal Key $i: $UNSEAL_KEY${SHELL_TEXT_RESET}"
  done
  echo -e "${SHELL_TEXT_INFO}Once the keys are securely distributed, manually delete the init-keys.txt file for security purposes.${SHELL_TEXT_RESET}"
)