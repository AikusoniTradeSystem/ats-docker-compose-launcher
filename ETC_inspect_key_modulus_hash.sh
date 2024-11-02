#!/bin/bash

# 도커 컨테이너 내부의 인증서 파일의 모듈러스 해시값을 출력하는 스크립트
# 인자가 제대로 제공되지 않으면 사용법 안내
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <container_name> <target_directory>"
  echo "eg. $0 my_container /etc/ssl/certs"
  exit 1
fi

# 인자로 받은 컨테이너 이름과 타겟 디렉토리 설정
CONTAINER_NAME="$1"
TARGET_DIR="$2"

# 도커 컨테이너 내부의 모든 .crt와 .key 파일을 처리
for file in $(docker exec "$CONTAINER_NAME" /bin/sh -c "find $TARGET_DIR -type f \( -name '*.crt' -o -name '*.key' \)"); do
  echo -ne "Processing ... $file\r"

  # 파일 확장자에 따라 분기 처리
  if [[ "$file" == *.crt ]]; then
    # .crt 파일인 경우 x509로 모듈러스 추출
    MD5=$(docker exec "$CONTAINER_NAME" cat "$file" | openssl x509 -noout -modulus 2>/dev/null | openssl md5)
  elif [[ "$file" == *.key ]]; then
    # .key 파일인 경우 rsa로 모듈러스 추출
    MD5=$(docker exec "$CONTAINER_NAME" cat "$file" | openssl rsa -noout -modulus 2>/dev/null | openssl md5)
  fi
  echo -ne "\r$MD5 ... $file\n"
done