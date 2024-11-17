#!/bin/bash

# ==============================================
# Script Name:  Publish Vault AppRole Secret Script
# Description:  This script publishes the Vault AppRole secret.
# Information:  This script is executed by other scripts to publish the Vault AppRole secret.
# ==============================================

if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo -e "Error: This script must be executed from another shell script."
  exit 1
fi

(
  source CMN_load_function.sh

  APP_ROLE_PREFIX=""
  VAULT_POLICY_TOKEN=""

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --app_role_prefix=*) APP_ROLE_PREFIX="${1#*=}"; shift ;;
      --vault_policy_token=*) VAULT_POLICY_TOKEN="${1#*=}"; shift ;;
      *) echo -e "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  ROLE_NAME="sub-policy-${APP_ROLE_PREFIX}-role"

  echo -e "APP_ROLE_PREFIX: $APP_ROLE_PREFIX"
  echo -e "ROLE_NAME: $ROLE_NAME"
#  echo -e "VAULT_POLICY_TOKEN: $VAULT_POLICY_TOKEN"

  # Vault의 앱롤 시크릿 획득
  docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault read "auth/approle/role/${ROLE_NAME}/role-id"
  docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault write -f "auth/approle/role/${ROLE_NAME}/secret-id"
)
