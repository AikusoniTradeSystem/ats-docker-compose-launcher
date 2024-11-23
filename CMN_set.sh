#!/bin/bash

# ==============================================
# Script Name:	Set Util
# Description:	This script provides a set structure for shell scripts. (It is using a file to store the set.)
# ==============================================


# 실행 확인
if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo -e "${SHELL_TEXT_ERROR}Error: This script must be executed from another shell script.${SHELL_TEXT_RESET}"
  exit 1
fi

(
  source CMN_load_function.sh

  show_help() {
      log e "Usage: $0 [options]"
      log e ""
      log e "Options:"
      log e "  --file=VALUE        File for storing the set"
      log e "  --add=VALUE         Add a Value to the set (can be used multiple times)"
      log e "  --a=VALUE           Add a Value to the set (can be used multiple times)"
      log e "  --remove=VALUE      Remove a Value from the set (can be used multiple times)"
      log e "  --r=VALUE           Remove a Value from the set (can be used multiple times)"
      log e "  --help              Show this help message and exit"
      log e ""
      log e "Example:"
      log e "  $0 --file=set.txt --add=VALUE1 --a=VALUE2 --remove=VALUE3 --r=VALUE4"
      exit 0
  }

  TMP_SET=()
  TO_ADD=()
  TO_REMOVE=()

  FILE_PROV=false

  # 명령줄 인수로 다양한 형태의 unseal 키들을 받기
  while [[ "$#" -gt 0 ]]; do
      case $1 in
          --file=*)
              FILE="${1#*=}"
              FILE_PROV=true
              shift
              ;;
          --a=*|--add=*)
              # 다양한 형식의 키에서 VALUE 부분을 추출하여 배열에 저장
              TO_ADD+=("${1#*=}")
              shift
              ;;
          --r=*|--remove=*)
              # 다양한 형식의 키에서 VALUE 부분을 추출하여 배열에 저장
              TO_REMOVE+=("${1#*=}")
              shift
              ;;
          --help)
              show_help
              exit 0
              ;;
          *)
              log e "Unknown option: $1" >&2
              show_help
              exit 1
              ;;
      esac
  done

  if [ "$FILE_PROV" = false ]; then
    log e "Error: No file provided."
    show_help
    exit 2
  fi

  if [ -f "$FILE" ]; then
    while IFS= read -r line
    do
      TMP_SET+=("$line")
    done < "$FILE"
  fi

  contains() {
      local value="$1"
      for item in "${TMP_SET[@]}"; do
          if [ "$item" == "$value" ]; then
              return 0
          fi
      done
      return 1
  }

  # 값 추가 (중복 방지)
  for value in "${TO_ADD[@]}"; do
      if ! contains "$value"; then
          TMP_SET+=("$value")
          log i "Added: $value"
      else
          log w "Skipped (duplicate): $value"
      fi
  done

  # 값 제거
  for value in "${TO_REMOVE[@]}"; do
      TMP_SET=("${TMP_SET[@]/$value}")
      log i "Removed: $value"
  done

  # 결과를 파일에 저장
  printf "%s\n" "${TMP_SET[@]}" > "$FILE"
  # 값 추가 (중복 방지)
  for value in "${TO_ADD[@]}"; do
      if ! contains "$value"; then
          TMP_SET+=("$value")
          echo "Added: $value"
      else
          echo "Skipped (duplicate): $value"
      fi
  done

  # 값 제거
  for value in "${TO_REMOVE[@]}"; do
      TMP_SET=("${TMP_SET[@]/$value}")
      echo "Removed: $value"
  done

  # 결과를 파일에 저장
  printf "%s\n" "${TMP_SET[@]}" > "$FILE"
  sed -i '/^$/d' "$FILE"  # 공백 라인 제거

  log s "Set updated in file: $FILE"
)