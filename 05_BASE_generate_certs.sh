#!/bin/bash

if [ "$0" = "sh" ] || [ "$0" = "bash" ]; then
  echo "Error: This script must be executed from another shell script."
  exit 1
fi

(
  SERVER_NAME=""
  CERT_PATH="./credentials/certs"

  # 명령행 인자를 처리하는 while 루프
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --server_name=*) SERVER_NAME="${1#*=}"; shift ;;
      --cert_path=*) CERT_PATH="${1#*=}"; shift ;;
      *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
  done

  echo "SERVER_NAME: $DB_VAULT_ID"
  echo "CERT_PATH: $CERT_PATH"

  SERVER_CERT_PATH="${CERT_PATH}/server/${SERVER_NAME}"
  CLIENT_CERT_PATH="${CERT_PATH}/client/${SERVER_NAME}"
  CA_CERT_PATH="${CERT_PATH}/ca/${SERVER_NAME}"

  # CNF 파일 경로
  SERVER_KEY_CNF_FILE="./key_conf/server/${SERVER_NAME}.cnf"

  TERMINAL_WIDTH=$(tput cols)
  printf "\e[0;33m%${TERMINAL_WIDTH}s\e[0m\n" | tr ' ' '='

  echo -e "\e[1;32mGenerating certificates for ${SERVER_NAME}...\e[0m"

  echo -e "\e[0;32mCreating directories for ${SERVER_NAME}...\e[0m"
  mkdir -p ${SERVER_CERT_PATH}
  mkdir -p ${CLIENT_CERT_PATH}
  mkdir -p ${CA_CERT_PATH}

  echo -e "\e[0;32mGenerating server key for ${SERVER_NAME}...\e[0m"
  openssl genrsa -out ${SERVER_CERT_PATH}/server.key 4096

  # 키 설정 파일이 있으면 -config 옵션 사용, 없으면 기본 생성
  if [ -f "$SERVER_KEY_CNF_FILE" ]; then
    echo -e "\e[0;32mKey configuration file found: $SERVER_KEY_CNF_FILE\e[0m"
    echo -e "\e[0;32mGenerating CSR with config file for ${SERVER_NAME}...\e[0m"
    openssl req -new -key ${SERVER_CERT_PATH}/server.key -out ${SERVER_CERT_PATH}/server.csr -config "$SERVER_KEY_CNF_FILE"
    echo -e "\e[0;32mSigning server certificate for ${SERVER_NAME} using the config file...\e[0m"
    openssl x509 -req -in ${SERVER_CERT_PATH}/server.csr -signkey ${SERVER_CERT_PATH}/server.key -out ${SERVER_CERT_PATH}/server.crt -days 365 -extensions v3_req -extfile "$SERVER_KEY_CNF_FILE"
  else
    echo -e "\e[0;31mNo key configuration file found for ${SERVER_NAME}.\e[0m"
    echo -e "\e[0;32mGenerating CSR without a config file for ${SERVER_NAME}...\e[0m"
    openssl req -new -key ${SERVER_CERT_PATH}/server.key -out ${SERVER_CERT_PATH}/server.csr
    echo -e "\e[0;32mSigning server certificate for ${SERVER_NAME} without a config file...\e[0m"
    openssl x509 -req -in ${SERVER_CERT_PATH}/server.csr -signkey ${SERVER_CERT_PATH}/server.key -out ${SERVER_CERT_PATH}/server.crt -days 365
  fi

  TERMINAL_WIDTH=$(tput cols)
  printf "\e[0;33m%${TERMINAL_WIDTH}s\e[0m\n" | tr ' ' '-'

  echo -e "\e[0;32mGenerating client key and certificate for ${SERVER_NAME}...\e[0m"
  openssl genrsa -out ${CLIENT_CERT_PATH}/client.key 4096
  openssl req -new -key ${CLIENT_CERT_PATH}/client.key -out ${CLIENT_CERT_PATH}/client.csr -subj "/CN=${SERVER_NAME}_client"
  openssl x509 -req -in ${CLIENT_CERT_PATH}/client.csr -CA ${SERVER_CERT_PATH}/server.crt -CAkey ${SERVER_CERT_PATH}/server.key -out ${CLIENT_CERT_PATH}/client.crt -days 365 -CAcreateserial

  echo -e "\e[0;32mCopying server certificate to CA directory for ${SERVER_NAME}...\e[0m"
  cp ${SERVER_CERT_PATH}/server.crt ${CA_CERT_PATH}/ca.crt

  echo -e "\e[1;32m==> Finished generating certificates for ${SERVER_NAME}.\e[0m"

  TERMINAL_WIDTH=$(tput cols)
  printf "\e[0;33m%${TERMINAL_WIDTH}s\e[0m\n" | tr ' ' '='
)