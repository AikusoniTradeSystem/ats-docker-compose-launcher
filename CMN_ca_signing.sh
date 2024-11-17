#!/bin/bash

# ========================================
# Script Name:	Sign CSR with CA
# Description:  This script signs a CSR with the CA key.
# ========================================

(
  source CMN_load_function.sh

  EXTENSIONS="v3_req"

  CA_KEY_PATH="${ROOT_CA_PRIVATE_KEY_PATH}"     # CA 비밀키 파일 경로
  CA_CERT_PATH="${ROOT_CA_CERT_FILE_PATH}"               # CA 인증서 파일 경로
  DAYS=365                                        # 인증서 유효기간

  # 입력 인자 확인
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      --ca_key_path=*) CA_KEY_PATH="${1#*=}"; shift ;;
      --ca_cert_path=*) CA_CERT_PATH="${1#*=}"; shift ;;
      --csr=*) CSR_FILE="${1#*=}"; shift ;;
      --output=*) OUTPUT_CERT="${1#*=}"; shift ;;
      --conf=*) CONFIG_FILE="${1#*=}"; shift ;;
      --extensions=*) EXTENSIONS="${1#*=}"; shift ;;
      --days=*) DAYS="${1#*=}"; shift ;;
      *) log e "Unknown parameter passed: $1"; exit 1 ;;
    esac
  done

  # 필수 인자 확인
  if [ -z "$CSR_FILE" ] || [ -z "$OUTPUT_CERT" ]; then
    log e "Usage: $0 --ca_key_path <ca_key_path> --ca_cert_path <ca_cert_path> --csr <csr_file> --output <output_cert> [--conf <config_file>]"
    exit 1
  fi

  # 서명된 인증서 생성
  log i "Signing CSR with ca key..."
  log d "ca key path: $CA_KEY_PATH"
  log d "ca cert path: $CA_CERT_PATH"
  log d "CSR file: $CSR_FILE"
  log d "Output certificate: $OUTPUT_CERT"

  log d "Current directory: $(pwd)"
  # --conf 인자가 있는 경우 SAN 포함
  if [ -n "$CONFIG_FILE" ]; then
    if [ ! -f "$CONFIG_FILE" ]; then
      log e "SAN configuration file not found: $CONFIG_FILE" >&2
      exit 1
    fi
    log d "Using SAN configuration file: $CONFIG_FILE"
    try openssl x509 -req -in "$CSR_FILE" -CA "$CA_CERT_PATH" -CAkey "$CA_KEY_PATH" -CAcreateserial -out "$OUTPUT_CERT" -days "${DAYS}" -extfile "$CONFIG_FILE" -extensions "${EXTENSIONS}"
  else
    # --conf 인자가 없는 경우 기본 설정으로 인증서 생성
    log w "No SAN configuration file provided. Using default settings."
    try openssl x509 -req -in "$CSR_FILE" -CA "$CA_CERT_PATH" -CAkey "$CA_KEY_PATH" -CAcreateserial -out "$OUTPUT_CERT" -days "${DAYS}"
  fi

  # 결과 확인
  if [ $? -eq 0 ]; then
    log s "Signed certificate saved to: $OUTPUT_CERT"
  else
    log e "Failed to sign the certificate." >&2
    exit 1
  fi
)