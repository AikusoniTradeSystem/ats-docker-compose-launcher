#!/bin/bash

if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo "Error: This script must be executed from another shell script."
  exit 1
fi

(
  VAULT_CONTAINER_NAME="ats-vault"

  ENGINE_TYPE=""
  ENGINE_NAME=""
  VAULT_POLICY_TOKEN=""

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --engine_type=*) ENGINE_TYPE="${1#*=}"; shift ;;
      --engine_name=*) ENGINE_NAME="${1#*=}"; shift ;;
      --vault_policy_token=*) VAULT_POLICY_TOKEN="${1#*=}"; shift ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  echo "ENGINE_TYPE: $ENGINE_TYPE"
  echo "ENGINE_NAME: $ENGINE_NAME"
#  echo "VAULT_POLICY_TOKEN: $VAULT_POLICY_TOKEN"

  docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault ${ENGINE_TYPE} enable "${ENGINE_NAME}"
)
