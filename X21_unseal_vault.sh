#!/bin/bash

(
  # Unseal 키를 저장할 배열
  UNSEAL_KEYS=()

  # 명령줄 인수로 unseal 키들을 받기
  while [[ "$#" -gt 0 ]]; do
      case $1 in
          --unseal_key_*)
              # unseal_key_N에서 N을 추출하여 배열에 저장
              UNSEAL_KEYS+=("${1#*=}")
              shift
              ;;
          *)
              echo "Unknown option: $1" >&2
              exit 1
              ;;
      esac
  done

  # Unseal 키가 제공되지 않았으면 오류 출력
  if [ ${#UNSEAL_KEYS[@]} -eq 0 ]; then
      echo "Error: No unseal keys provided."
      exit 1
  fi

  # Vault가 unseal되어 있는지 확인하는 함수
  check_vault_status() {
      docker exec ats-vault vault status | grep "Sealed" | awk '{print $2}'
  }

  # Vault가 잠겨있는지 확인
  if [ "$(check_vault_status)" == "true" ]; then
    echo "Vault is sealed. Unsealing..."

    # Unseal 키 배열을 순차적으로 사용하여 Vault를 unseal
    for key in "${UNSEAL_KEYS[@]}"
    do
      docker exec ats-vault vault operator unseal "$key"
      # Vault가 unseal 되었는지 다시 확인
      if [ "$(check_vault_status)" == "false" ]; then
        echo "Vault unsealed successfully."
        exit 0
      fi
    done

    echo "Vault is still sealed after providing unseal keys."
  else
    echo "Vault is already unsealed."
  fi
)