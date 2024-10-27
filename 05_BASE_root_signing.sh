#!/bin/bash

EXTENSIONS="v3_req"

# 입력 인자 확인
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --csr=*) CSR_FILE="${1#*=}"; shift ;;
    --output=*) OUTPUT_CERT="${1#*=}"; shift ;;
    --conf=*) CONFIG_FILE="${1#*=}"; shift ;;
    --extensions=*) EXTENSIONS="${1#*=}"; shift ;;
    *) echo "Unknown parameter passed: $1"; exit 1 ;;
  esac
done

# 필수 인자 확인
if [ -z "$CSR_FILE" ] || [ -z "$OUTPUT_CERT" ]; then
  echo -e "Usage: $0 --csr <csr_file> --output <output_cert> [--conf <config_file>]"
  exit 1
fi

ROOT_KEY_PATH="${ROOT_PRIVATE_KEY_FILE_PATH}"     # 루트 비밀키 파일 경로
ROOT_CA_PATH="${ROOT_CA_FILE_PATH}"               # 루트 CA 인증서 파일 경로

# 서명된 인증서 생성
echo -e "Signing CSR with root key...\n"
echo -e "Root key path: $ROOT_KEY_PATH"
echo -e "CSR file: $CSR_FILE"
echo -e "Output certificate: $OUTPUT_CERT"

# --conf 인자가 있는 경우 SAN 포함
if [ -n "$CONFIG_FILE" ]; then
  if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "SAN configuration file not found: $CONFIG_FILE" >&2
    exit 1
  fi
  echo -e "Using SAN configuration file: $CONFIG_FILE"
  openssl x509 -req -in "$CSR_FILE" -CA "$ROOT_CA_PATH" -CAkey "$ROOT_KEY_PATH" -out "$OUTPUT_CERT" -days 365 -extfile "$CONFIG_FILE" -extensions "$EXTENSIONS"
else
  # --conf 인자가 없는 경우 기본 설정으로 인증서 생성
  openssl x509 -req -in "$CSR_FILE" -CA "$ROOT_CA_PATH" -CAkey "$ROOT_KEY_PATH" -out "$OUTPUT_CERT" -days 365
fi

# 결과 확인
if [ $? -eq 0 ]; then
  echo -e "Signed certificate saved to: $OUTPUT_CERT"
else
  echo -e "Failed to sign the certificate." >&2
  exit 1
fi