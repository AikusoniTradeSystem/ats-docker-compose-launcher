#!/bin/bash

# 에러 체크 함수 정의
function assertResult() {
  if [ $? -ne 0 ]; then
    echo "Error occurred while executing: $1"
    exit 1
  fi
}

# 색상 지원 환경에 따라 해시값을 다른 색상으로 출력하는 함수
generate_colored_hash() {
  local hash_value="$1"
  local colored_hash=""
  local reset_color="\033[0m"

  # 색상 지원 환경 감지
  local color_mode
  if [[ $(tput colors) -ge 256 ]]; then
    if [[ $TERM =~ "256color" ]]; then
      color_mode="256"
    else
      color_mode="truecolor"
    fi
  else
    color_mode="16"
  fi

  # 해시값을 6자리씩 나눠 색상 적용
  for ((i = 0; i < ${#hash_value}; i += 6)); do
    local segment="${hash_value:i:6}"

    # 색상 코드 생성 및 적용
    if [[ $color_mode == "truecolor" ]]; then
      # 24비트 색상 (True Color) 지원
      local r=$((16#${segment:0:2}))
      local g=$((16#${segment:2:2}))
      local b=$((16#${segment:4:2}))
      colored_hash+=$(echo -e "\033[38;2;${r};${g};${b}m${segment}${reset_color}")
    elif [[ $color_mode == "256" ]]; then
      # 256색 팔레트 지원
      local color_code=$((16#${segment:0:2} % 256))
      colored_hash+=$(echo -e "\033[38;5;${color_code}m${segment}${reset_color}")
    else
      # 16색 팔레트 지원
      local color_code=$((16#${segment:0:2} % 8 + 30))  # 30~37 범위의 ANSI 색상 코드 사용
      colored_hash+=$(echo -e "\033[${color_code}m${segment}${reset_color}")
    fi
  done

  # 최종 색상 적용된 해시값 반환
  echo -e "$colored_hash"
}
