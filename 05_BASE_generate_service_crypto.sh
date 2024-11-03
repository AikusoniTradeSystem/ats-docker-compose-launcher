#!/bin/bash

# 실행 확인
if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo -e "${SHELL_TEXT_ERROR}Error: This script must be executed from another shell script."
  exit 1
fi

(
  source load_function.sh

  SERVICE_NAME=""
  SERVER_KEY_CNF_FILE_PATH=""
  CLIENT_KEY_CNF_FILE_PATH=""
  SERVER_PRIVATE_KEY_PATH=""
  CLIENT_PRIVATE_KEY_PATH=""
  SERVER_CSR_FILE_PATH=""
  CLIENT_CSR_FILE_PATH=""
  SERVER_CERT_FILE_PATH=""
  CLIENT_CERT_FILE_PATH=""
  SERVER_PUBLIC_CERT_PATH=""
  CLIENT_PUBLIC_CERT_PATH=""
  SERVER_SELF_SIGNED_CERT_PATH=""
  SERVER_SELF_SIGNED_PUBLIC_CERT_PATH=""
  SERVER_SIGNED_CLIENT_CERT_PATH=""
  SERVER_SIGNED_CLIENT_PUBLIC_CERT_PATH=""
  SIGNING_SCRIPT_CMD=""
  SERVER_EXTENSIONS="v3_req"
  CLIENT_EXTENSIONS="client_cert"

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --service_name=*) SERVICE_NAME="${1#*=}"; shift ;;
      --server_key_cnf_file_path=*) SERVER_KEY_CNF_FILE_PATH="${1#*=}"; shift ;;
      --client_key_cnf_file_path=*) CLIENT_KEY_CNF_FILE_PATH="${1#*=}"; shift ;;
      --server_private_key_path=*) SERVER_PRIVATE_KEY_PATH="${1#*=}"; shift ;;
      --client_private_key_path=*) CLIENT_PRIVATE_KEY_PATH="${1#*=}"; shift ;;
      --server_csr_file_path=*) SERVER_CSR_FILE_PATH="${1#*=}"; shift ;;
      --client_csr_file_path=*) CLIENT_CSR_FILE_PATH="${1#*=}"; shift ;;
      --server_cert_file_path=*) SERVER_CERT_FILE_PATH="${1#*=}"; shift ;;
      --client_cert_file_path=*) CLIENT_CERT_FILE_PATH="${1#*=}"; shift ;;
      --server_public_cert_path=*) SERVER_PUBLIC_CERT_PATH="${1#*=}"; shift ;;
      --client_public_cert_path=*) CLIENT_PUBLIC_CERT_PATH="${1#*=}"; shift ;;
      --server_self_signed_cert_path=*) SERVER_SELF_SIGNED_CERT_PATH="${1#*=}"; shift ;;
      --server_self_signed_public_cert_path=*) SERVER_SELF_SIGNED_PUBLIC_CERT_PATH="${1#*=}"; shift ;;
      --server_signed_client_cert_path=*) SERVER_SIGNED_CLIENT_CERT_PATH="${1#*=}"; shift ;;
      --server_signed_client_public_cert_path=*) SERVER_SIGNED_CLIENT_PUBLIC_CERT_PATH="${1#*=}"; shift ;;
      --server_extensions=*) SERVER_EXTENSIONS="${1#*=}"; shift ;;
      --client_extensions=*) CLIENT_EXTENSIONS="${1#*=}"; shift ;;
      --signing_script_cmd=*) SIGNING_SCRIPT_CMD="${1#*=}"; shift ;;
      *) log e "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  # 인자 목록 출력
  log i "Generating certificates for ${SERVICE_NAME}..."
  log d "SERVICE_NAME: ${SERVICE_NAME}"
  log d "SERVER_KEY_CNF_FILE_PATH: ${SERVER_KEY_CNF_FILE_PATH}"
  log d "CLIENT_KEY_CNF_FILE_PATH: ${CLIENT_KEY_CNF_FILE_PATH}"
  log d "SERVER_PRIVATE_KEY_PATH: ${SERVER_PRIVATE_KEY_PATH}"
  log d "CLIENT_PRIVATE_KEY_PATH: ${CLIENT_PRIVATE_KEY_PATH}"
  log d "SERVER_CSR_FILE_PATH: ${SERVER_CSR_FILE_PATH}"
  log d "CLIENT_CSR_FILE_PATH: ${CLIENT_CSR_FILE_PATH}"
  log d "SERVER_CERT_FILE_PATH: ${SERVER_CERT_FILE_PATH}"
  log d "CLIENT_CERT_FILE_PATH: ${CLIENT_CERT_FILE_PATH}"
  log d "SERVER_PUBLIC_CERT_PATH: ${SERVER_PUBLIC_CERT_PATH}"
  log d "CLIENT_PUBLIC_CERT_PATH: ${CLIENT_PUBLIC_CERT_PATH}"
  log d "SERVER_SELF_SIGNED_CERT_PATH: ${SERVER_SELF_SIGNED_CERT_PATH}"
  log d "SERVER_SELF_SIGNED_PUBLIC_CERT_PATH: ${SERVER_SELF_SIGNED_PUBLIC_CERT_PATH}"
  log d "SERVER_SIGNED_CLIENT_CERT_PATH: ${SERVER_SIGNED_CLIENT_CERT_PATH}"
  log d "SERVER_SIGNED_CLIENT_PUBLIC_CERT_PATH: ${SERVER_SIGNED_CLIENT_PUBLIC_CERT_PATH}"
  log d "SIGNING_SCRIPT_CMD: ${SIGNING_SCRIPT_CMD}"
  log i "========================================"

  log i "Generating server key for ${SERVICE_NAME}..."
  openssl genrsa -out "${SERVER_PRIVATE_KEY_PATH}" 4096

  # CSR 생성
  if [ -f "$SERVER_KEY_CNF_FILE_PATH" ]; then
    log i "Generating server CSR with config file for ${SERVICE_NAME}..."
    openssl req -new -key "${SERVER_PRIVATE_KEY_PATH}" -out "${SERVER_CSR_FILE_PATH}" -config "${SERVER_KEY_CNF_FILE_PATH}"
  else
    log w "No key configuration file found for ${SERVICE_NAME}."
    log w "Generating server CSR without a config file for ${SERVICE_NAME}..."
    openssl req -new -key "${SERVER_PRIVATE_KEY_PATH}" -out "${SERVER_CSR_FILE_PATH}"
  fi

  # 서명 스크립트 호출
  if [ -n "$SIGNING_SCRIPT_CMD" ]; then
    FULL_SIGNING_SCRIPT_CMD="$SIGNING_SCRIPT_CMD --csr=\"${SERVER_CSR_FILE_PATH}\" --output=\"${SERVER_CERT_FILE_PATH}\""
    if [ -f "$SERVER_KEY_CNF_FILE_PATH" ]; then
      FULL_SIGNING_SCRIPT_CMD="$FULL_SIGNING_SCRIPT_CMD --conf=\"$SERVER_KEY_CNF_FILE_PATH\" --extensions=\"$SERVER_EXTENSIONS\""
    fi

    log i "Signing server certificate for ${SERVICE_NAME} using the signing script... ${FULL_SIGNING_SCRIPT_CMD}"
    eval "$FULL_SIGNING_SCRIPT_CMD"
  fi

  if [ -n "$SERVER_SELF_SIGNED_CERT_PATH" ]; then
    log i "Self-signing the server certificate for ${SERVICE_NAME}..."
    openssl x509 -req -in "${SERVER_CSR_FILE_PATH}" -signkey "${SERVER_PRIVATE_KEY_PATH}" -out "${SERVER_SELF_SIGNED_CERT_PATH}" -days 365 --extfile "$SERVER_KEY_CNF_FILE_PATH" -extensions "$SERVER_EXTENSIONS"
  fi

  log i "----------------------------------------"
  log i "Generating client key and certificate for ${SERVICE_NAME}..."
  openssl genrsa -out "${CLIENT_PRIVATE_KEY_PATH}" 4096
  if [ -f "$CLIENT_KEY_CNF_FILE_PATH" ]; then
    log i "Generating client CSR with config file for ${SERVICE_NAME}..."
    openssl req -new -key "${CLIENT_PRIVATE_KEY_PATH}" -out "${CLIENT_CSR_FILE_PATH}" -config "${CLIENT_KEY_CNF_FILE_PATH}" -subj "/CN=${SERVICE_NAME}_client"
  else
    log w "No client key configuration file found for ${SERVICE_NAME}."
    log w "Generating CSR without a config file for ${SERVICE_NAME}..."
    openssl req -new -key "${CLIENT_PRIVATE_KEY_PATH}" -out "${CLIENT_CSR_FILE_PATH}" -subj "/CN=${SERVICE_NAME}_client"
  fi

  if [ -n "$SIGNING_SCRIPT_CMD" ]; then
    FULL_SIGNING_SCRIPT_CMD="$SIGNING_SCRIPT_CMD --csr=\"${CLIENT_CSR_FILE_PATH}\" --output=\"${CLIENT_CERT_FILE_PATH}\""
    if [ -f "$CLIENT_KEY_CNF_FILE_PATH" ]; then
      FULL_SIGNING_SCRIPT_CMD="$FULL_SIGNING_SCRIPT_CMD --conf=\"$CLIENT_KEY_CNF_FILE_PATH\" --extensions=\"$CLIENT_EXTENSIONS\""
    fi

    log i "Signing client certificate for ${SERVICE_NAME} using the signing script... ${FULL_SIGNING_SCRIPT_CMD}"
    eval "$FULL_SIGNING_SCRIPT_CMD"
  fi

  if [ -n "$SERVER_SIGNED_CLIENT_CERT_PATH" ]; then
    log i "Signing the client certificate for ${SERVICE_NAME} with the server certificate..."
    openssl x509 -req -in "${CLIENT_CSR_FILE_PATH}" -CA "${SERVER_CERT_FILE_PATH}" -CAkey "${SERVER_PRIVATE_KEY_PATH}" -out "${SERVER_SIGNED_CLIENT_CERT_PATH}" -days 365 --extfile "$CLIENT_KEY_CNF_FILE_PATH" -extensions "$CLIENT_EXTENSIONS" -CAcreateserial
  fi

  log i "Copying server certificate to CA directory for ${SERVICE_NAME}..."
  cp "${SERVER_CERT_FILE_PATH}" "${SERVER_PUBLIC_CERT_PATH}"
  cp "${CLIENT_CERT_FILE_PATH}" "${CLIENT_PUBLIC_CERT_PATH}"

  if [ -n "$SERVER_SELF_SIGNED_PUBLIC_CERT_PATH" ]; then
    cp "${SERVER_SELF_SIGNED_CERT_PATH}" "${SERVER_SELF_SIGNED_PUBLIC_CERT_PATH}"
  fi
  if [ -n "$SERVER_SIGNED_CLIENT_PUBLIC_CERT_PATH" ]; then
    cp "${SERVER_SIGNED_CLIENT_CERT_PATH}" "${SERVER_SIGNED_CLIENT_PUBLIC_CERT_PATH}"
  fi

  log s "==> Finished generating certificates for ${SERVICE_NAME}."
  log s "========================================"
)