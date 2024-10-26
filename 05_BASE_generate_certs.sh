#!/bin/bash

if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo "Error: This script must be executed from another shell script."
  exit 1
fi

(
  # 텍스트 색상 및 포맷 설정
  YELLOW="\e[0;33m"
  GREEN="\e[0;32m"
  BOLD_GREEN="\e[1;32m"
  RED="\e[0;31m"
  RESET_STYLE="\e[0m"
  HBAR1="${YELLOW}$(printf '=%.0s' $(seq 1 $(tput cols)))${RESET_STYLE}"
  HBAR2="${YELLOW}$(printf '-%.0s' $(seq 1 $(tput cols)))${RESET_STYLE}"

  SERVER_NAME=""
  CERT_PATH="./credentials/certs"

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --server_name=*) SERVER_NAME="${1#*=}"; shift ;;
      --cert_path=*) CERT_PATH="${1#*=}"; shift ;;
      *) echo -e "${RED}Unknown option: $1${RESET_STYLE}" >&2; exit 1 ;;
    esac
  done

  echo "SERVER_NAME: $DB_VAULT_ID"
  echo "CERT_PATH: $CERT_PATH"

  SERVER_CERT_PATH="${CERT_PATH}/server/${SERVER_NAME}"
  CLIENT_CERT_PATH="${CERT_PATH}/client/${SERVER_NAME}"
  CA_CERT_PATH="${CERT_PATH}/ca/${SERVER_NAME}"

  # CNF 파일 경로
  SERVER_KEY_CNF_FILE="./key_conf/server/${SERVER_NAME}.cnf"

  echo -e "$HBAR1"
  echo -e "${BOLD_GREEN}Generating certificates for ${SERVER_NAME}...${RESET_STYLE}"

  echo -e "${GREEN}Creating directories for ${SERVER_NAME}...${RESET_STYLE}"
  mkdir -p ${SERVER_CERT_PATH}
  mkdir -p ${CLIENT_CERT_PATH}
  mkdir -p ${CA_CERT_PATH}

  echo -e "${GREEN}Generating server key for ${SERVER_NAME}...${RESET_STYLE}"
  openssl genrsa -out ${SERVER_CERT_PATH}/server.key 4096

  # 키 설정 파일이 있으면 -config 옵션 사용, 없으면 기본 생성
  if [ -f "$SERVER_KEY_CNF_FILE" ]; then
    echo -e "${GREEN}Key configuration file found: $SERVER_KEY_CNF_FILE${RESET_STYLE}"
    echo -e "${GREEN}Generating CSR with config file for ${SERVER_NAME}...${RESET_STYLE}"
    openssl req -new -key ${SERVER_CERT_PATH}/server.key -out ${SERVER_CERT_PATH}/server.csr -config "$SERVER_KEY_CNF_FILE"
    echo -e "${GREEN}Signing server certificate for ${SERVER_NAME} using the config file...${RESET_STYLE}"
    openssl x509 -req -in ${SERVER_CERT_PATH}/server.csr -signkey ${SERVER_CERT_PATH}/server.key -out ${SERVER_CERT_PATH}/server.crt -days 365 -extensions v3_req -extfile "$SERVER_KEY_CNF_FILE"
  else
    echo -e "${RED}No key configuration file found for ${SERVER_NAME}.${RESET_STYLE}"
    echo -e "${GREEN}Generating CSR without a config file for ${SERVER_NAME}...${RESET_STYLE}"
    openssl req -new -key ${SERVER_CERT_PATH}/server.key -out ${SERVER_CERT_PATH}/server.csr
    echo -e "${GREEN}Signing server certificate for ${SERVER_NAME} without a config file...${RESET_STYLE}"
    openssl x509 -req -in ${SERVER_CERT_PATH}/server.csr -signkey ${SERVER_CERT_PATH}/server.key -out ${SERVER_CERT_PATH}/server.crt -days 365
  fi

  echo -e "$HBAR2"
  echo -e "${GREEN}Generating client key and certificate for ${SERVER_NAME}...${RESET_STYLE}"
  openssl genrsa -out ${CLIENT_CERT_PATH}/client.key 4096
  openssl req -new -key ${CLIENT_CERT_PATH}/client.key -out ${CLIENT_CERT_PATH}/client.csr -subj "/CN=${SERVER_NAME}_client"
  openssl x509 -req -in ${CLIENT_CERT_PATH}/client.csr -CA ${SERVER_CERT_PATH}/server.crt -CAkey ${SERVER_CERT_PATH}/server.key -out ${CLIENT_CERT_PATH}/client.crt -days 365 -CAcreateserial

  echo -e "${GREEN}Copying server certificate to CA directory for ${SERVER_NAME}...${RESET_STYLE}"
  cp ${SERVER_CERT_PATH}/server.crt ${CA_CERT_PATH}/ca.crt

  echo -e "${BOLD_GREEN}==> Finished generating certificates for ${SERVER_NAME}.${RESET_STYLE}"
  echo -e "$HBAR1"
)