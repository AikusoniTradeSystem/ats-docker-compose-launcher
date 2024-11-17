#!/bin/bash

# ==============================================
# Script Name:  Print Vault Policy Token
# Description:  This script extracts the policy token from the Vault policy file and prints it.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  POLICY_NAME="admin-policy"

  case "$1" in
    --policy_name)
      POLICY_NAME="$2"
      ;;
    *)
      log e "Usage: $0 --policy_name <policy_name>"
      exit 1
      ;;
  esac

  # Vault Policy Token 출력
  VAULT_POLICY_TOKEN=$(awk -F'"' '/"client_token"/ {print $4}' "${VAULT_CREDENTIAL_INIT_PATH}/${POLICY_NAME}.json")
  log i "Vault Policy Name: $POLICY_NAME"
  log i "Vault Policy Token: $VAULT_POLICY_TOKEN"
)