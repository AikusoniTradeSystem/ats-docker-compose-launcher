#!/bin/bash

# ==============================================
# Script Name:    Enable Vault Engine
# Description:    This script enables the specified engine in Vault.
# Information:    This script is used by other scripts to enable the specified engine in Vault.
# ==============================================

if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo -e "Error: This script must be executed from another shell script."
  exit 1
fi

(
  source load_function.sh

  ENGINE_TYPE=""
  ENGINE_NAME=""
  ENGINE_PATH=""
  VAULT_POLICY_TOKEN=""

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --vault_policy_token=*) VAULT_POLICY_TOKEN="${1#*=}"; shift ;;
      --engine_type=*) ENGINE_TYPE="${1#*=}"; shift ;;
      --engine_name=*) ENGINE_NAME="${1#*=}"; shift ;;
      --path=*) ENGINE_PATH="${1#*=}"; shift ;;
      *) echo -e "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  log i "Enabling Vault Engine: ${ENGINE_NAME}"
  log i "Engine Type: ${ENGINE_TYPE}"
  log i "Engine Name: ${ENGINE_NAME}"
  log i "Engine Path: ${ENGINE_PATH}"

  if [ -z "$ENGINE_PATH" ]; then
    log i "No path specified. Enabling engine at default path."
    docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault ${ENGINE_TYPE} enable "${ENGINE_NAME}"
  else
    log i "Enabling engine at path: ${ENGINE_PATH}"
    docker exec -e VAULT_TOKEN="${VAULT_POLICY_TOKEN}" ${VAULT_CONTAINER_NAME} vault ${ENGINE_TYPE} enable "${ENGINE_PATH}/${ENGINE_NAME}"
  fi

  exit_on_error "Failed to enable Vault Engine: ${ENGINE_NAME}" 1
)