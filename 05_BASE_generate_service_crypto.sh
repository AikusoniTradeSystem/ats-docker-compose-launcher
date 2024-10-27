#!/bin/bash

# 실행 확인
if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo -e "${SHELL_TEXT_ERROR}Error: This script must be executed from another shell script.${SHELL_TEXT_RESET}"
  exit 1
fi

(
  SERVICE_NAME=""
  SERVER_CRYPTO_OUTPUT_PATH=""
  CLIENT_CRYPTO_OUTPUT_PATH=""
  CA_CRYPTO_OUTPUT_PATH=""
  SERVER_KEY_CNF_FILE_PATH=""
  SIGNING_SCRIPT_PATH=""
  EXTENSIONS="v3_req"

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --service_name=*) SERVICE_NAME="${1#*=}"; shift ;;
      --server_crypto_path=*) SERVER_CRYPTO_OUTPUT_PATH="${1#*=}"; shift ;;
      --client_crypto_path=*) CLIENT_CRYPTO_OUTPUT_PATH="${1#*=}"; shift ;;
      --ca_crypto_path=*) CA_CRYPTO_OUTPUT_PATH="${1#*=}"; shift ;;
      --server_key_cnf_file_path=*) SERVER_KEY_CNF_FILE_PATH="${1#*=}"; shift ;;
      --signing_script=*) SIGNING_SCRIPT_PATH="${1#*=}"; shift ;;
      *) echo -e "${SHELL_TEXT_ERROR}Unknown option: $1${SHELL_TEXT_RESET}" >&2; exit 1 ;;
    esac
  done

  # 인자 목록 출력
  echo -e "${SHELL_TEXT_INFO}SERVICE_NAME: ${SERVICE_NAME}${SHELL_TEXT_RESET}"
  echo -e "${SHELL_TEXT_INFO}SERVER_CRYPTO_OUTPUT_PATH: ${SERVER_CRYPTO_OUTPUT_PATH}${SHELL_TEXT_RESET}"
  echo -e "${SHELL_TEXT_INFO}CLIENT_CRYPTO_OUTPUT_PATH: ${CLIENT_CRYPTO_OUTPUT_PATH}${SHELL_TEXT_RESET}"
  echo -e "${SHELL_TEXT_INFO}CA_CRYPTO_OUTPUT_PATH: ${CA_CRYPTO_OUTPUT_PATH}${SHELL_TEXT_RESET}"
  echo -e "${SHELL_TEXT_INFO}SERVER_KEY_CNF_FILE_PATH: ${SERVER_KEY_CNF_FILE_PATH}${SHELL_TEXT_RESET}"

  echo -e "$MAIN_HBAR"
  echo -e "${SHELL_TEXT_INFO}Generating certificates for ${SERVICE_NAME}...${SHELL_TEXT_RESET}"

  echo -e "${SHELL_TEXT_INFO}Creating directories for ${SERVICE_NAME}...${SHELL_TEXT_RESET}"
  mkdir -p "${SERVER_CRYPTO_OUTPUT_PATH}" "${CLIENT_CRYPTO_OUTPUT_PATH}" "${CA_CRYPTO_OUTPUT_PATH}"

  echo -e "${SHELL_TEXT_INFO}Generating server key for ${SERVICE_NAME}...${SHELL_TEXT_RESET}"
  openssl genrsa -out "${SERVER_CRYPTO_OUTPUT_PATH}/server.key" 4096

  # CSR 생성
  echo -e "${SHELL_TEXT_INFO}Generating CSR with config file for ${SERVICE_NAME}...${SHELL_TEXT_RESET}"
  if [ -f "$SERVER_KEY_CNF_FILE_PATH" ]; then
    openssl req -new -key "${SERVER_CRYPTO_OUTPUT_PATH}/server.key" -out "${SERVER_CRYPTO_OUTPUT_PATH}/server.csr" -config "$SERVER_KEY_CNF_FILE_PATH"
  else
    echo -e "${SHELL_TEXT_ERROR}No key configuration file found for ${SERVICE_NAME}.${SHELL_TEXT_RESET}"
    echo -e "${SHELL_TEXT_INFO}Generating CSR without a config file for ${SERVICE_NAME}...${SHELL_TEXT_RESET}"
    openssl req -new -key "${SERVER_CRYPTO_OUTPUT_PATH}/server.key" -out "${SERVER_CRYPTO_OUTPUT_PATH}/server.csr"
  fi

  # 서명 스크립트 호출
  if [ -n "$SIGNING_SCRIPT_PATH" ] && [ -f "$SIGNING_SCRIPT_PATH" ]; then
    echo -e "${SHELL_TEXT_INFO}Submitting CSR to signing script: $SIGNING_SCRIPT_PATH${SHELL_TEXT_RESET}"
    if [ -f "$SERVER_KEY_CNF_FILE_PATH" ]; then
      bash "$SIGNING_SCRIPT_PATH" --csr="${SERVER_CRYPTO_OUTPUT_PATH}/server.csr" --output="${SERVER_CRYPTO_OUTPUT_PATH}/server.crt" --conf="$SERVER_KEY_CNF_FILE_PATH" --extensions="$EXTENSIONS"
    else
      bash "$SIGNING_SCRIPT_PATH" --csr="${SERVER_CRYPTO_OUTPUT_PATH}/server.csr" --output="${SERVER_CRYPTO_OUTPUT_PATH}/server.crt"
    fi
  else
    echo -e "${SHELL_TEXT_WARNING}Signing script not found or not specified. Proceeding with self-signing...${SHELL_TEXT_RESET}"
  fi

  echo -e "${SHELL_TEXT_INFO}Self-signing the server certificate for ${SERVICE_NAME}...${SHELL_TEXT_RESET}"
  openssl x509 -req -in "${SERVER_CRYPTO_OUTPUT_PATH}/server.csr" -signkey "${SERVER_CRYPTO_OUTPUT_PATH}/server.key" -out "${SERVER_CRYPTO_OUTPUT_PATH}/server_self.crt" -days 365 --extfile "$SERVER_KEY_CNF_FILE_PATH" -extensions "$EXTENSIONS"

  echo -e "$SUB_HBAR"
  echo -e "${SHELL_TEXT_INFO}Generating client key and certificate for ${SERVICE_NAME}...${SHELL_TEXT_RESET}"
  openssl genrsa -out "${CLIENT_CRYPTO_OUTPUT_PATH}/client.key" 4096
  openssl req -new -key "${CLIENT_CRYPTO_OUTPUT_PATH}/client.key" -out "${CLIENT_CRYPTO_OUTPUT_PATH}/client.csr" -subj "/CN=${SERVICE_NAME}_client"
  openssl x509 -req -in "${CLIENT_CRYPTO_OUTPUT_PATH}/client.csr" -CA "${SERVER_CRYPTO_OUTPUT_PATH}/server_self.crt" -CAkey "${SERVER_CRYPTO_OUTPUT_PATH}/server.key" -out "${CLIENT_CRYPTO_OUTPUT_PATH}/client.crt" -days 365 -CAcreateserial

  echo -e "${SHELL_TEXT_SUCCESS}Copying server certificate to CA directory for ${SERVICE_NAME}...${SHELL_TEXT_RESET}"
  cp "${SERVER_CRYPTO_OUTPUT_PATH}/server.crt" "${CA_CRYPTO_OUTPUT_PATH}/ca.crt"
  cp "${SERVER_CRYPTO_OUTPUT_PATH}/server_self.crt" "${CA_CRYPTO_OUTPUT_PATH}/ca_self.crt"

  echo -e "${SHELL_TEXT_BOLD_GREEN}==> Finished generating certificates for ${SERVICE_NAME}.${SHELL_TEXT_RESET}"
  echo -e "$MAIN_HBAR"
)