#!/bin/bash

# ==============================================
# Script Name:  Unseal Vault
# Description:  This script unseals the Vault container.
# ==============================================

(
  source load_env.sh

  # 도움말 함수
  show_help() {
      echo -e "Usage: $0 [options]"
      echo -e ""
      echo -e "Options:"
      echo -e "  --key=VALUE         Provide an unseal key (can be used multiple times)"
      echo -e "  --unseal_key=VALUE  Provide an unseal key (can be used multiple times)"
      echo -e "  --k=VALUE           Provide an unseal key (can be used multiple times)"
      echo -e "  --uk=VALUE          Provide an unseal key (can be used multiple times)"
      echo -e "  --help              Show this help message and exit"
      echo -e ""
      echo -e "Example:"
      echo -e "  $0 --key=XSqlmDCUlp9 --unseal_key=Xsej23k8 --k=KSkD93js --uk=Aik178s13"
      exit 0
  }

  # Unseal 키를 저장할 배열
  UNSEAL_KEYS=()

  # 명령줄 인수로 다양한 형태의 unseal 키들을 받기
  while [[ "$#" -gt 0 ]]; do
      case $1 in
          --key=*|--unseal_key=*|--k=*|--uk=*)
              # 다양한 형식의 키에서 VALUE 부분을 추출하여 배열에 저장
              UNSEAL_KEYS+=("${1#*=}")
              shift
              ;;
          --help)
              show_help
              exit 0
              ;;
          *)
              echo -e "Unknown option: $1" >&2
              show_help
              exit 1
              ;;
      esac
  done

  # Unseal 키가 제공되지 않았으면 오류 출력
  if [ ${#UNSEAL_KEYS[@]} -eq 0 ]; then
      echo -e "Error: No unseal keys provided."
      exit 1
  fi

  # Vault가 unseal되어 있는지 확인하는 함수
  check_vault_status() {
      docker exec ats-vault vault status | grep "Sealed" | awk '{print $2}'
  }

  # Vault가 잠겨있는지 확인
  if [ "$(check_vault_status)" == "true" ]; then
    echo -e "Vault is sealed. Unsealing..."

    # Unseal 키 배열을 순차적으로 사용하여 Vault를 unseal
    for key in "${UNSEAL_KEYS[@]}"
    do
      docker exec ats-vault vault operator unseal "$key"
      # Vault가 unseal 되었는지 다시 확인
      if [ "$(check_vault_status)" == "false" ]; then
        echo -e "Vault unsealed successfully."
        exit 0
      fi
    done

    echo -e "Vault is still sealed after providing unseal keys."
  else
    echo -e "Vault is already unsealed."
  fi
)