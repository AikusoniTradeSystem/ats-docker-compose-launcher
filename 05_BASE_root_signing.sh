#!/bin/bash

# 입력 인자 확인
if [ "$#" -ne 2 ]; then
  echo -e "Usage: $0 <csr_file> <output_cert>"
  exit 1
fi

(
  CSR_FILE="$1"           # CSR 파일
  OUTPUT_CERT="$2"       # 출력할 인증서 경로
  ROOT_KEY_PATH="${ROOT_PRIVATE_KEY_FILE_PATH}"     # 루트 비밀키 파일 경로
  ROOT_CA_PATH="${ROOT_CA_FILE_PATH}"          # 루트 CA 인증서 파일 경로

  # 서명된 인증서 생성
  echo -e "Signing CSR with root key...\n"
  echo -e "Root key path: $ROOT_KEY_PATH"
  echo -e "CSR file: $CSR_FILE"
  echo -e "Output certificate: $OUTPUT_CERT"

  openssl x509 -req -in "$CSR_FILE" -CA "$ROOT_CA_PATH" -CAkey "$ROOT_KEY_PATH" -out "$OUTPUT_CERT" -days 365

  if [ $? -eq 0 ]; then
    echo -e "Signed certificate saved to: $OUTPUT_CERT"
  else
    echo -e "Failed to sign the certificate." >&2
    exit 1
  fi
)