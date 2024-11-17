#!/bin/bash

# ==============================================
# Script Name:  functions for ats shell scripts
# Description:	This script provides common functions for shell scripts in the ATS project.
# ==============================================

# ==============================================
# Function List
# ==============================================

# ==============================================
# log functions
# ----------------------------------------------
# log : Log the message with the specified log level. (usage: log <log_level> <message> / e.g., log ERROR "Error occurred.")
# - supporting log levels: ERROR, SUCCESS, WARNING, IMPORTANT, INFO, DEBUG, VERBOSE (short: e, s, w, imp, i, d, v)
# loge : Log the message with the ERROR log level.
# logs : Log the message with the SUCCESS log level.
# logw : Log the message with the WARNING log level.
# logimp : Log the message with the IMPORTANT log level.
# logi : Log the message with the INFO log level.
# logd : Log the message with the DEBUG log level.
# logv : Log the message with the VERBOSE log level.
# ==============================================

# ==============================================
# stack trace function
# ----------------------------------------------
# stack_trace : Print the stack trace of the current function call.
# ==============================================

# =============================================
# error handling functions
# ----------------------------------------------
# exit_on_error : Check the error status of the previous command and exit if an error occurs.
# handle_error : Handle the error and exit the script.
# try : Execute the command and handle the error (similar to try-catch).
# - usage: try <command>
# ==============================================

# ==============================================
# temporary directory functions
# ----------------------------------------------
# create_temp_dir : Create a temporary directory and map it.
# - usage: create_temp_dir <key>
# - recommendation usage : create_temp_dir get_current_pid (to create a temporary directory with the current process ID)
# cleanup_temp_dirs : Clean up temporary directories when exiting.
# - usage: cleanup_temp_dirs <key>
# - recommendation usage : cleanup_temp_dirs get_current_pid (to clean up the temporary directory with the current process ID)
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
    local line_number="N/A"
    if [ -n "${BASH_SOURCE[1]}" ]; then
        script_name=$(basename "${BASH_SOURCE[1]}")
    fi
    if [ -n "${BASH_LINENO[0]}" ]; then
        line_number="${BASH_LINENO[0]}"
    fi
    # timestamp example: 2024-11-10 12:34:56.789+09:00
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S.%3N%:z")
    local log_format="${LOG_FORMAT:-%s [%s] [%s] (line %d) %s}"
    shift

    # 로그 레벨에 따른 색상 설정
    case $level in
        ERROR|e)
            local color="${SHELL_TEXT_ERROR}"
            level="ERROR"
            ;;
        SUCCESS|s)
            local color="${SHELL_TEXT_SUCCESS}"
            level="SUCCESS"
            ;;
        WARNING|w)
            local color="${SHELL_TEXT_WARNING}"
            level="WARNING"
            ;;
        IMPORTANT|imp)
            local color="${SHELL_TEXT_IMPORTANT}"
            level="IMPORTANT"
            ;;
        INFO|i)
            local color="${SHELL_TEXT_INFO}"
            level="INFO"
            ;;
        DEBUG|d)
            local color="${SHELL_TEXT_DEBUG}"
            level="DEBUG"
            ;;
        VERBOSE|v)
            local color="${SHELL_TEXT_VERBOSE}"
            level="VERBOSE"
            ;;
        *)
            local color=""
            ;;
    esac

    # 로그 출력
    if [ -n "$color" ]; then
        printf "${color}${log_format}${SHELL_TEXT_RESET}\n" "$timestamp" "$level" "$script_name" "$line_number" "$message"
    else
        printf "${log_format}\n" "$timestamp" "$level" "$script_name" "$line_number" "$message"
    fi
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

function stack_trace() {
  local offset="${1:-0}"
  local error_level="${2:-DEBUG}"
  log "$error_level" "Stack Trace:"
  local i
  for ((i = offset; i < ${#FUNCNAME[@]}; i++)); do
    log "$error_level" "  ${FUNCNAME[$i]}() in ${BASH_SOURCE[$i+1]} (line: ${BASH_LINENO[$i]})"
  done
}

# 에러 체크 후 메시지 띄우고 나가는 함수
function exit_on_error() {
  local last_exit_code=$?
  local message="$1"
  local exit_code="${2:-1}"
  local file_name="${BASH_SOURCE[1]}"
  local line_number="${BASH_LINENO[0]}"

  if [ "$last_exit_code" -ne 0 ]; then
    log e "Error Occurred : $message"
    log e "Error occurred in '$file_name' (line : '$line_number')."
    log e "Last Exit code: $last_exit_code"
    stack_trace 1 "ERROR"
    exit "$exit_code"
  fi
}

# 에러 처리 함수
function handle_error() {
  local exit_code=$?
  local command=$1
  log e "Command that failed: $command"
  stack_trace 2 "ERROR"
  exit "$exit_code"
}

# try-catch 유사한 기능
function try() {
  local command="$@"
  trap "handle_error '$command'" ERR
  "$@"
  trap - ERR
}

# 임시 디렉토리 생성 및 매핑
function create_temp_dir() {
  local key="$1"
  local temp_dir_list_file="./.temp_dirs_list.$key"
  local temp_dir
  temp_dir=$(mktemp -d)

  # 배열에 매핑 저장
  echo "$temp_dir" >> "$temp_dir_list_file"  # temp_dir_list.txt에 디렉토리 경로 기록

  echo "$temp_dir"  # 디렉토리 경로 반환
}

function print_temp_dirs() {
  local key="$1"
  echo "Temporary directories for key: $key"
  echo "${TEMP_DIRS["$key"]}"
}

# 임시 디렉토리 정리
function cleanup_temp_dirs() {
  local key="$1"
  local temp_dir_list_file="./.temp_dirs_list.$key"

  if [ -f "$temp_dir_list_file" ]; then
    while IFS= read -r temp_dir; do
      if [ -n "$temp_dir" ]; then
        echo "Cleaning up temporary directory: $temp_dir"
        rm -rf "$temp_dir"
      fi
    done < "$temp_dir_list_file"

    # 정리 후 파일 초기화
    rm "${temp_dir_list_file}"
  else
    echo "No temporary directories to clean up."
  fi
}
