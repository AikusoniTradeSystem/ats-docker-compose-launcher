#!/bin/bash

# 에러 체크 함수 정의
function assertResult() {
  if [ $? -ne 0 ]; then
    echo "Error occurred while executing: $1"
    exit 1
  fi
}