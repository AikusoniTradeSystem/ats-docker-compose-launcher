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

  # Vault의 앱롤 시크릿 획득
  docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault read auth/approle/role/${APP_ROLE_PREFIX}-approle/role-id
  docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write -f auth/approle/role/${APP_ROLE_PREFIX}-approle/secret-id
)
