#!/bin/bash

###
# 환경변수를 로딩한다.
# 로딩시 기존에 로딩되었던 환경변수에서 변경점이 있는지 확인을 하고, 변경된 내용이 있으면 출력한다.
###

CONFIG_FILES_PATH="${CONFIG_FILES_PATH:-./sample_configs}"

# 상대 경로 기반 config_trace 폴더 설정
SCRIPT_DIR=$(dirname "$0")
TRACE_DIR="$SCRIPT_DIR/config_trace"

# config_trace 폴더가 없으면 생성
mkdir -p "$TRACE_DIR"

# 임시 파일 경로 설정
TEMP_ENV_FILE_BEFORE="$TRACE_DIR/last_tracked_env_vars"
TEMP_ENV_FILE_AFTER="$TRACE_DIR/current_tracked_env_vars"
TEMP_ENV_DIFF="$TRACE_DIR/env_diff_output"

# 해싱 알고리즘 설정 (예: sha256, sha512, md5), 없으면 해싱 없이 저장
CONFIG_TRACE_HASH_ALGORITHM="${CONFIG_TRACE_HASH_ALGORITHM:-}"

# 색상 코드 설정
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET_STYLE="\e[0m"

# 1. env_configs 디렉터리에서 모든 .envconfig 파일 목록 가져오기
CONFIG_FILES=($(find "$CONFIG_FILES_PATH" -type f -name "*.envconfig" | sort))

# 1. 서브 설정 파일에서 환경 변수 목록 추출
function extract_tracked_vars() {
    local file="$1"
    grep -E '^[^#[:space:]]+[[:space:]]*=' "$file" | sed 's/^[[:space:]]*\([^=[:space:]]*\)[[:space:]]*=[[:space:]]*\(.*\)/\1=\2/'
}

# 2. 특정 변수 목록만 현재 환경 변수 상태로 저장, 값만 해싱하거나 원래 값 저장
function save_env_state() {
    local file="$1"
    > "$file"  # 파일 초기화

    shift
    for entry in "$@"; do
        # key=value 형태에서 키와 값을 분리
        local key="${entry%%=*}"
        local value="${entry#*=}"
        local value_hash

        # 선택한 해싱 알고리즘이 설정된 경우 해싱 수행, 아니면 원래 값 사용
        if [[ -n "$CONFIG_TRACE_HASH_ALGORITHM" ]]; then
            case "$CONFIG_TRACE_HASH_ALGORITHM" in
                sha256)
                    value_hash=$(echo -n "$value" | sha256sum | awk '{print $1}')
                    ;;
                sha512)
                    value_hash=$(echo -n "$value" | sha512sum | awk '{print $1}')
                    ;;
                md5)
                    value_hash=$(echo -n "$value" | md5sum | awk '{print $1}')
                    ;;
                *)
                    echo -e "Error: Unsupported hashing algorithm '$CONFIG_TRACE_HASH_ALGORITHM'."
                    exit 1
                    ;;
            esac
        else
            value_hash="$value"  # 해싱 없이 원래 값 사용
        fi

        # 파일에 키=값 형태로 저장
        echo -e "$key=$value_hash" >> "$file"
    done
}

# 3. 환경 변수 변경 감지 함수
function detect_env_changes() {
    if [ -f "$TEMP_ENV_FILE_BEFORE" ]; then
        echo -e "Comparing environment changes..."

        # 변경된 내용 감지
        comm -3 "$TEMP_ENV_FILE_BEFORE" "$TEMP_ENV_FILE_AFTER" > "$TEMP_ENV_DIFF"

        if [ -s "$TEMP_ENV_DIFF" ]; then
            # 추가, 삭제 구분하여 출력
            echo -e "${RED}Detected changes in tracked environment variables:${RESET_STYLE}"
            grep -E "^\t\t>" "$TEMP_ENV_DIFF" | sed "s/^\t\t>/${GREEN}Added:/; s/$/${RESET_STYLE}/"
            grep -E "^\t<" "$TEMP_ENV_DIFF" | sed "s/^\t< /${YELLOW}Removed:/; s/$/${RESET_STYLE}/"
        else
            echo -e "${GREEN}No changes in tracked environment variables.${RESET_STYLE}"
        fi
    else
        echo -e "No previous environment snapshot found. Saving current state for future comparison."
    fi
    rm -f "$TEMP_ENV_DIFF"
}

# 4. 추적 변수 초기화
declare -a TRACKED_VARS=()

# 각 서브 설정 파일에서 변수 추출 및 실제 세션에 적용
for config_file in "${CONFIG_FILES[@]}"; do
    if [ -f "$config_file" ]; then
        # 추적할 변수 목록에 배열 형태로 추가
        while IFS= read -r line; do
            TRACKED_VARS+=("$line")
        done < <(extract_tracked_vars "$config_file")
    else
        echo -e "Warning: Config file '$config_file' not found."
    fi
done

# 추적할 변수 초기 상태 저장
save_env_state "$TEMP_ENV_FILE_AFTER" "${TRACKED_VARS[@]}"

# 이전 상태와 현재 상태 비교
detect_env_changes

# 5. 현재 세션에 환경 변수 설정
for config_file in "${CONFIG_FILES[@]}"; do
    if [ -f "$config_file" ]; then
      set -a
      source "$config_file"
      set +a
    else
        echo -e "Warning: Config file '$config_file' not found."
    fi
done

# 6. 현재 환경 변수 파일을 마지막 상태 파일로 업데이트
cp "$TEMP_ENV_FILE_AFTER" "$TEMP_ENV_FILE_BEFORE"
rm -f "$TEMP_ENV_FILE_AFTER"
