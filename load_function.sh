#!/bin/bash

# 에러 체크 함수 정의
function assertResult() {
  if [ $? -ne 0 ]; then
    echo "Error occurred while executing: $1"
    exit 1
  fi
}

# 색상 지원 환경에 따라 해시값을 다른 색상으로 출력하는 함수
function generate_colored_hash() {
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

# 로그 레벨 정의
LOG_LEVEL=${LOG_LEVEL:-3} # 0: ERROR, 1: SUCCESS,WARNING, 2: INFO, 3: DEBUG, 4: VERBOSE

SHELL_TEXT_ERROR=${SHELL_TEXT_ERROR:-"\e[0;31m"}
SHELL_TEXT_WARNING=${SHELL_TEXT_WARNING:-"\e[0;33m"}
SHELL_TEXT_INFO=${SHELL_TEXT_INFO:-"\e[0;36m"}
SHELL_TEXT_DEBUG=${SHELL_TEXT_DEBUG:-"\e[0;37m"}
SHELL_TEXT_VERBOSE=${SHELL_TEXT_VERBOSE:-"\e[0;90m"}
SHELL_TEXT_SUCCESS=${SHELL_TEXT_SUCCESS:-"\e[0;32m"}
SHELL_TEXT_RESET=${SHELL_TEXT_RESET:-"\e[0m"}

function log() {
    local level=$1
    shift
    local message="$@"
    local script_name="N/A"
    if [ -n "${BASH_SOURCE[1]}" ]; then
        script_name=$(basename "${BASH_SOURCE[1]}")
    fi
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # 로그 레벨을 7자로 고정하고 색상 적용
    case $level in
          ERROR|e)
              [ $LOG_LEVEL -ge 0 ] && printf "${SHELL_TEXT_ERROR}[%s] [%-7s] [%s] (line %d) %s${SHELL_TEXT_RESET}\n" "$timestamp" "ERROR" "$script_name" "$LINENO" "$message"
              ;;
          SUCCESS|s)
              [ $LOG_LEVEL -ge 1 ] && printf "${SHELL_TEXT_SUCCESS}[%s] [%-7s] [%s] (line %d) %s${SHELL_TEXT_RESET}\n" "$timestamp" "SUCCESS" "$script_name" "$LINENO" "$message"
              ;;
          WARNING|w)
              [ $LOG_LEVEL -ge 1 ] && printf "${SHELL_TEXT_WARNING}[%s] [%-7s] [%s] (line %d) %s${SHELL_TEXT_RESET}\n" "$timestamp" "WARNING" "$script_name" "$LINENO" "$message"
              ;;
          INFO|i)
              [ $LOG_LEVEL -ge 2 ] && printf "${SHELL_TEXT_INFO}[%s] [%-7s] [%s] (line %d) %s${SHELL_TEXT_RESET}\n" "$timestamp" "INFO" "$script_name" "$LINENO" "$message"
              ;;
          DEBUG|d)
              [ $LOG_LEVEL -ge 3 ] && printf "${SHELL_TEXT_DEBUG}[%s] [%-7s] [%s] (line %d) %s${SHELL_TEXT_RESET}\n" "$timestamp" "DEBUG" "$script_name" "$LINENO" "$message"
              ;;
          VERBOSE|v)
              [ $LOG_LEVEL -ge 4 ] && printf "${SHELL_TEXT_VERBOSE}[%s] [%-7s] [%s] (line %d) %s${SHELL_TEXT_RESET}\n" "$timestamp" "VERBOSE" "$script_name" "$LINENO" "$message"
              ;;
          *)
              printf "[%s] [%-7s] [%s] (line %d) %s\n" "$timestamp" "UNKNOWN" "$script_name" "$LINENO" "$message"
              ;;
      esac
}

function loge() {
    log ERROR "$@"
}

function logs() {
    log SUCCESS "$@"
}

function logw() {
    log WARNING "$@"
}

function logi() {
    log INFO "$@"
}

function logd() {
    log DEBUG "$@"
}

function logv() {
    log VERBOSE "$@"
}
