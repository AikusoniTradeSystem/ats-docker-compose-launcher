#!/bin/bash

# ==============================================
# Script Name:	Generate Intermediate CA Base Script
# Description:	This script is base scripts to generate the intermediate CA key and intermediate CA certificate using the custom configuration file.
# Information:  This script is used by other scripts.
# ==============================================

# 실행 확인
if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo -e "${SHELL_TEXT_ERROR}Error: This script must be executed from another shell script.${SHELL_TEXT_RESET}"
  exit 1
fi

(
  source load_function.sh

  SIGNING_SCRIPT_CMD=""
  EXTENSIONS="v3_intermediate_ca"
  INTERMEDIATE_CA_PRIVATE_KEY_PATH=""
  INTERMEDIATE_CA_CSR_FILE_PATH=""
  INTERMEDIATE_CA_CERT_PATH=""
  INTERMEDIATE_CA_CNF_PATH=""
  INTERMEDIATE_CA_CERT_PUB_FILE_PATH=""

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --signing_script_cmd=*) SIGNING_SCRIPT_CMD="${1#*=}"; shift ;;
      --intermediate_ca_private_key_path=*) INTERMEDIATE_CA_PRIVATE_KEY_PATH="${1#*=}"; shift ;;
      --intermediate_ca_csr_file_path=*) INTERMEDIATE_CA_CSR_FILE_PATH="${1#*=}"; shift ;;
      --intermediate_ca_cert_path=*) INTERMEDIATE_CA_CERT_PATH="${1#*=}"; shift ;;
      --intermediate_ca_cnf_path=*) INTERMEDIATE_CA_CNF_PATH="${1#*=}"; shift ;;
      --intermediate_ca_cert_pub_file_path=*) INTERMEDIATE_CA_CERT_PUB_FILE_PATH="${1#*=}"; shift ;;
      --extensions=*) EXTENSIONS="${1#*=}"; shift ;;
      *) log e "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  # 인자 목록 출력
  log i "Generating intermediate CA key and intermediate CA certificate using the custom configuration file..."
  log d "SIGNING_SCRIPT_CMD: ${SIGNING_SCRIPT_CMD}"
  log d "INTERMEDIATE_CA_PRIVATE_KEY_PATH: ${INTERMEDIATE_CA_PRIVATE_KEY_PATH}"
  log d "INTERMEDIATE_CA_CSR_FILE_PATH: ${INTERMEDIATE_CA_CSR_FILE_PATH}"
  log d "INTERMEDIATE_CA_CERT_PATH: ${INTERMEDIATE_CA_CERT_PATH}"
  log d "INTERMEDIATE_CA_CNF_PATH: ${INTERMEDIATE_CA_CNF_PATH}"
  log d "INTERMEDIATE_CA_CERT_PUB_FILE_PATH: ${INTERMEDIATE_CA_CERT_PUB_FILE_PATH}"
  log d "EXTENSIONS: ${EXTENSIONS}"

  # Generate Intermediate CA key
  try openssl genrsa -out "${INTERMEDIATE_CA_PRIVATE_KEY_PATH}" 4096

  # Generate intermediate CA certificate using the custom config file
  try openssl req -new -key "${INTERMEDIATE_CA_PRIVATE_KEY_PATH}" \
    -out "${INTERMEDIATE_CA_CSR_FILE_PATH}" \
    -config "${INTERMEDIATE_CA_CNF_PATH}"

  if [ -n "$SIGNING_SCRIPT_CMD" ]; then
    FULL_SIGNING_SCRIPT_CMD="$SIGNING_SCRIPT_CMD --csr=\"${INTERMEDIATE_CA_CSR_FILE_PATH}\" --output=\"${INTERMEDIATE_CA_CERT_PATH}\""

    if [ -f "$INTERMEDIATE_CA_CNF_PATH" ]; then
      FULL_SIGNING_SCRIPT_CMD="$FULL_SIGNING_SCRIPT_CMD --conf=\"$INTERMEDIATE_CA_CNF_PATH\" --extensions=\"$EXTENSIONS\""
    fi
    eval "$FULL_SIGNING_SCRIPT_CMD"
    exit_on_error "Intermediate CA certificate signing failed."
  else
    log e "No signing script found."
    exit 1
  fi

  cp "${INTERMEDIATE_CA_CERT_PATH}" "${INTERMEDIATE_CA_CERT_PUB_FILE_PATH}"

  log s "Intermediate CA key and intermediate CA certificate have been generated successfully using the custom configuration file."
)