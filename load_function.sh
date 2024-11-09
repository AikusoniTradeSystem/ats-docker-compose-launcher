#!/bin/bash

# ==============================================
# Script Name:  functions for ats shell scripts
# Description:	This script provides common functions for shell scripts in the ATS project.
# ==============================================

# ==============================================
# Function List
# ----------------------------------------------
# -- log functions -----------------------------
# log : Log the message with the specified log level. (usage: log <log_level> <message> / e.g., log ERROR "Error occurred.")
# - supporting log levels: ERROR, SUCCESS, WARNING, IMPORTANT, INFO, DEBUG, VERBOSE (short: e, s, w, imp, i, d, v)
# loge : Log the message with the ERROR log level.
# logs : Log the message with the SUCCESS log level.
# logw : Log the message with the WARNING log level.
# logimp : Log the message with the IMPORTANT log level.
# logi : Log the message with the INFO log level.
# logd : Log the message with the DEBUG log level.
# logv : Log the message with the VERBOSE log level.
# ----------------------------------------------
# -- error handling functions ------------------
# exit_on_error : Check the error status of the previous command and exit if an error occurs.
# handle_error : Handle the error and exit the script.
# try : Execute the command and handle the error (similar to try-catch).
# - usage: try <command>
# ==============================================

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
LOG_LEVEL=${LOG_LEVEL:-3} # 0: ERROR / 1: SUCCESS,WARNING,IMPORTANT / 2: INFO / 3: DEBUG / 4: VERBOSE

# 로그 색상 정의
SHELL_TEXT_ERROR=${SHELL_TEXT_ERROR:-"\e[0;31m"}
SHELL_TEXT_SUCCESS=${SHELL_TEXT_SUCCESS:-"\e[0;32m"}
SHELL_TEXT_WARNING=${SHELL_TEXT_WARNING:-"\e[0;33m"}
SHELL_TEXT_IMPORTANT=${SHELL_TEXT_IMPORTANT:-"\e[0;35m"}
SHELL_TEXT_INFO=${SHELL_TEXT_INFO:-"\e[0;36m"}
SHELL_TEXT_DEBUG=${SHELL_TEXT_DEBUG:-"\e[0;37m"}
SHELL_TEXT_VERBOSE=${SHELL_TEXT_VERBOSE:-"\e[0;90m"}
SHELL_TEXT_RESET=${SHELL_TEXT_RESET:-"\e[0m"}

# 로그 출력 함수
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
          IMPORTANT|imp)
              [ $LOG_LEVEL -ge 1 ] && printf "${SHELL_TEXT_IMPORTANT}[%s] [%-7s] [%s] (line %d) %s${SHELL_TEXT_RESET}\n" "$timestamp" "IMPORTANT" "$script_name" "$LINENO" "$message"
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

# 에러 로그 출력 함수
function loge() {
    log ERROR "$@"
}

# 성공 로그 출력 함수
function logs() {
    log SUCCESS "$@"
}

# 경고 로그 출력 함수
function logw() {
    log WARNING "$@"
}

# 중요 로그 출력 함수
function logimp() {
    log IMPORTANT "$@"
}

# 정보 로그 출력 함수
function logi() {
    log INFO "$@"
}

# 디버그 로그 출력 함수
function logd() {
    log DEBUG "$@"
}

# 상세 로그 출력 함수
function logv() {
    log VERBOSE "$@"
}

# 에러 체크 후 메시지 띄우고 나가는 함수
function exit_on_error() {
  local exit_code="${2:-1}"
  if [ $? -ne 0 ]; then
    log e "Error occurred: $1"
    log e "Last executed command: $BASH_COMMAND"
    exit "$exit_code"
  fi
}

# 에러 처리 함수 (유사한 catch)
function handle_error() {
  log e "An error occurred during the execution."
  log e "Last command: $1"
  exit 1
}

# try-catch 유사한 기능
function try() {
  local command="$@"
  trap 'handle_error "$command"' ERR
  "$@"
  trap - ERR
}