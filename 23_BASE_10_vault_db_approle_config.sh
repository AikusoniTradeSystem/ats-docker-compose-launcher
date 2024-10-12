#!/bin/bash

if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo "Error: This script must be executed from another shell script."
  exit 1
fi

(
  VAULT_CONTAINER_NAME="ats-vault"

  APP_ROLE_PREFIX=""
  VAULT_POLICY_TOKEN=""

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --app_role_prefix=*) APP_ROLE_PREFIX="${1#*=}"; shift ;;
      --vault_policy_token=*) VAULT_POLICY_TOKEN="${1#*=}"; shift ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  echo "APP_ROLE_PREFIX: $APP_ROLE_PREFIX"
#  echo "VAULT_POLICY_TOKEN: $VAULT_POLICY_TOKEN"

  # 정책 내용을 생성하여 파일에 저장
  POLICY_PATH="./credentials/vault/gen-policies/sub/approle"
  POLICY_FILE="${POLICY_PATH}/${APP_ROLE_PREFIX}-role.hcl"
  VAULT_POLICY_PATH="/vault/gen-policies/sub/approle"
  VAULT_POLICY_FILE="${VAULT_POLICY_PATH}/${APP_ROLE_PREFIX}-role.hcl"
  VAULT_POLICY_NAME="sub/approle/${APP_ROLE_PREFIX}-role"
  ROLE_NAME="sub-policy-${APP_ROLE_PREFIX}-role"

  echo "Creating policy file at: $POLICY_FILE"

  mkdir -p $POLICY_PATH
  cat <<EOF > "$POLICY_FILE"
path "database/creds/${APP_ROLE_PREFIX}-role" {
  capabilities = ["read"]
}
EOF

  chmod +r $POLICY_FILE

  echo "Policy file created at: $POLICY_FILE"

  # 컨테이너 내부에 정책 파일을 저장할 폴더 생성
  docker exec $VAULT_CONTAINER_NAME mkdir -p $VAULT_POLICY_PATH

  # 정책 파일을 컨테이너 내부로 복사
  docker cp "$POLICY_FILE" ${VAULT_CONTAINER_NAME}:"${VAULT_POLICY_FILE}"

  # Vault의 앱롤 설정 활성화
  docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault policy write "${VAULT_POLICY_NAME}" "${VAULT_POLICY_FILE}"
  docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write "auth/approle/role/${ROLE_NAME}" token_policies="${VAULT_POLICY_NAME}"

  echo "AppRole ${ROLE_NAME} (policy : ${VAULT_POLICY_NAME}) has been configured."
)
