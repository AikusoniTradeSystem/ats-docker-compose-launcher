#!/bin/bash

# ==============================================
# Script Name:	Generate Truststore JKS
# Description:	This script generates the Truststore JKS.
# ==============================================

(
  # 환경 변수 및 함수 로드
  source CMN_load_env.sh
  source CMN_load_function.sh

  # 필수 환경 변수 설정
  FULL_CHAIN_FILE="${INTER_CA2_PUBLIC_CHAIN_CERT_PATH}"
  ALIAS_PREFIX="ca_cert"

  export TRUSTSTORE_JKS_PATH="${TRUSTSTORE_JKS_PATH}"
  export TRUSTSTORE_JKS_PASSWORD="${TRUSTSTORE_JKS_PASSWORD}"

  # Truststore JKS를 위한 디렉토리 생성
  mkdir -p "${TRUSTSTORE_PATH}"

  # keytool 설치 여부 확인
  which keytool > /dev/null 2>&1
  exit_on_error "keytool is not installed."

  CERT_INDEX=1
  log i "Splitting the full chain certificate..."
  awk -v outdir="$TRUSTSTORE_PATH" 'BEGIN {certcount=0;}
       /BEGIN CERTIFICATE/ {certcount++; filename=sprintf("%s/cert%d.crt", outdir, certcount);}
       {print > filename}' "$FULL_CHAIN_FILE"
  exit_on_error "Failed to split the full chain certificate."

  log i "Listing the split certificates..."
  ls -1 "$TRUSTSTORE_PATH"/cert*.crt

  # Truststore JKS 생성

  log i "Generate Truststore JKS..."

  # 기존 Truststore JKS 파일이 존재하는 경우 삭제
  if [ -f "$TRUSTSTORE_JKS_PATH" ]; then
      log d "Deleting existing Truststore JKS file..."
      rm -f "$TRUSTSTORE_JKS_PATH"
      exit_on_error "Failed to delete existing Truststore JKS file."
  fi

  # 새로운 인증서 import
  for CERT_FILE in "$TRUSTSTORE_PATH"/cert*.crt; do
      ALIAS="${ALIAS_PREFIX}_${CERT_INDEX}"
      log d "Importing $CERT_FILE as alias $ALIAS..."
      keytool -importcert -trustcacerts -file "$CERT_FILE" -keystore "$TRUSTSTORE_JKS_PATH" \
              -storepass "$TRUSTSTORE_JKS_PASSWORD" -alias "$ALIAS" -noprompt
      exit_on_error "Error importing $CERT_FILE. Please check manually."

      log d "Successfully imported $CERT_FILE as $ALIAS."
      CERT_INDEX=$((CERT_INDEX + 1))
  done

  log s "Truststore JKS generated successfully."
  log imp "Please check the Truststore JKS file: $TRUSTSTORE_JKS_PATH"
  log imp "Please check the Truststore JKS password: $TRUSTSTORE_JKS_PASSWORD"
)