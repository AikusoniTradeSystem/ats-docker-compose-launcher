#!/bin/bash

# ==============================================
# Script Name:	Configure Vault Database AppRole
# Description:  This script configures the Vault database AppRole.
# Information:  This script is executed by other scripts to configure the Vault database AppRole.
# ==============================================

if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo -e "Error: This script must be executed from another shell script."
  exit 1
fi

(
  source CMN_load_function.sh

  DB_ALIAS=""
  APP_ROLE_PREFIX=""
  VAULT_POLICY_TOKEN=""

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --db_alias=*) DB_ALIAS="${1#*=}"; shift ;;
      --app_role_prefix=*) APP_ROLE_PREFIX="${1#*=}"; shift ;;
      --vault_policy_token=*) VAULT_POLICY_TOKEN="${1#*=}"; shift ;;
      *) log e "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  log d "DB_ALIAS: $DB_ALIAS"
  log d "APP_ROLE_PREFIX: $APP_ROLE_PREFIX"
#  log d "VAULT_POLICY_TOKEN: $VAULT_POLICY_TOKEN"

  # 정책 내용을 생성하여 파일에 저장
  POLICY_PATH="${VAULT_APPROLE_GEN_POLICY_PATH}"
  POLICY_FILE="${POLICY_PATH}/${APP_ROLE_PREFIX}-role.hcl"
  VAULT_POLICY_PATH="/vault/gen-policies/sub/approle"
  VAULT_POLICY_FILE="${VAULT_POLICY_PATH}/${APP_ROLE_PREFIX}-role.hcl"
  VAULT_POLICY_NAME="sub/approle/${APP_ROLE_PREFIX}-role"
  ROLE_NAME="sub-policy-${APP_ROLE_PREFIX}-role"

  log d "Creating policy file at: $POLICY_FILE"

  mkdir -p $POLICY_PATH
  cat <<EOF > "$POLICY_FILE"
path "auth/approle/login" {
  capabilities = ["create", "read", "update"]
}

path "database/creds/${DB_ALIAS}" {
  capabilities = ["read"]
}
EOF

  chmod +r $POLICY_FILE

  log d "Policy file created at: $POLICY_FILE"

  # 컨테이너 내부에 정책 파일을 저장할 폴더 생성
  docker exec $VAULT_CONTAINER_NAME mkdir -p $VAULT_POLICY_PATH

  # 정책 파일을 컨테이너 내부로 복사
  docker cp "$POLICY_FILE" ${VAULT_CONTAINER_NAME}:"${VAULT_POLICY_FILE}"

  # Vault의 앱롤 설정 활성화
  docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault policy write "${VAULT_POLICY_NAME}" "${VAULT_POLICY_FILE}"
  docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write "auth/approle/role/${ROLE_NAME}" token_policies="${VAULT_POLICY_NAME}"

  log d "AppRole ${ROLE_NAME} (policy : ${VAULT_POLICY_NAME}) has been configured."
)
