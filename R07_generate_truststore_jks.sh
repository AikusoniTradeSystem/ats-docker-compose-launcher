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
  export TRUSTSTORE_JKS_PATH="${TRUSTSTORE_JKS_PATH}"
  export TRUSTSTORE_JKS_PASSWORD="${TRUSTSTORE_JKS_PASSWORD}"
  export TRUSTSTORE_CA_CERT_PATH="${INTER_CA2_PUBLIC_CHAIN_CERT_PATH}"

  # Truststore JKS를 위한 디렉토리 생성
  mkdir -p "${TRUSTSTORE_PATH}"

  log i "Generate Truststore JKS..."

  # keytool 설치 여부 확인
  which keytool > /dev/null 2>&1
  exit_on_error "keytool is not installed."

  INTER_CA2_ALIAS="inter_ca2"

  # keystore에 alias가 존재하는지 확인
  if keytool -list -keystore "${TRUSTSTORE_JKS_PATH}" -storepass "${TRUSTSTORE_JKS_PASSWORD}" -alias "${INTER_CA2_ALIAS}" > /dev/null 2>&1; then
    log d "Alias '${INTER_CA2_ALIAS}' exists in keystore. Deleting it..."

    # 기존 alias 삭제
    keytool -delete -alias "${INTER_CA2_ALIAS}" -keystore "${TRUSTSTORE_JKS_PATH}" -storepass "${TRUSTSTORE_JKS_PASSWORD}" -noprompt
    exit_on_error "Failed to delete alias '${INTER_CA2_ALIAS}' from keystore."

    log d "Alias '${INTER_CA2_ALIAS}' successfully deleted."
  fi

  # 새로운 인증서 import
  log i "Importing new certificate for alias '${INTER_CA2_ALIAS}'..."
  keytool -import -trustcacerts -alias "${INTER_CA2_ALIAS}" -file "${TRUSTSTORE_CA_CERT_PATH}" -keystore "${TRUSTSTORE_JKS_PATH}" -storepass "${TRUSTSTORE_JKS_PASSWORD}" -noprompt
  exit_on_error "Failed to import certificate for alias '${INTER_CA2_ALIAS}'."

  log d "Certificate successfully imported for alias '${INTER_CA2_ALIAS}'."
)