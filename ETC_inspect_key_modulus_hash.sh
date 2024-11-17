#!/bin/bash

# ==============================================
# Script Name:	Inspect Key Modulus Hash
# Description:	This script outputs the modulus hash of the certificate file in the specified directory.
# ==============================================

# 지정 경로의 인증서 파일의 모듈러스 해시값을 출력하는 스크립트
# 인자가 제대로 제공되지 않으면 사용법 안내
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <target_directory>"
  echo "eg. $0 /etc/ssl/certs"
  exit 1
fi

source CMN_load_function.sh

# 인자로 받은 컨테이너 이름과 타겟 디렉토리 설정
TARGET_DIR="$1"

# 지정 경로 내부의 모든 .crt와 .key 파일을 처리
find "$TARGET_DIR" -type f \( -name '*.crt' -o -name '*.key' \) | while IFS= read -r file; do
  echo -ne "Processing ... $file\r"

  # 파일 확장자에 따라 분기 처리
  if [[ "$file" == *.crt ]]; then
    # .crt 파일인 경우 x509로 모듈러스 추출
    MD5=$(openssl x509 -in "$file" -noout -modulus 2>/dev/null | openssl md5)
  elif [[ "$file" == *.key ]]; then
    # .key 파일인 경우 rsa로 모듈러스 추출
    MD5=$(openssl rsa -in "$file" -noout -modulus 2>/dev/null | openssl md5)
  fi

  # MD5 해시값에서 "MD5" 부분과 해시값 분리
  md5_label=$(echo "$MD5" | awk '{print $1}')
  hash_value=$(echo "$MD5" | awk '{print $2}')

  # 해시값에만 색상 적용
  colored_hash=$(generate_colored_hash "$hash_value")

  # 결과 출력 (MD5 부분은 그대로, 해시값만 색상 적용)
  echo -e "\r$md5_label $colored_hash ... $file in this machine"
done