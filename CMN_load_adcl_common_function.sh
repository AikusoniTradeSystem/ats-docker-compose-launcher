#!/bin/bash

# ==============================================
# Script Name:  Common Functions of the ATS Docker Compose Launcher Project
# Description:	This script provides common functions.
# ==============================================

# ==============================================
# Function List
# ==============================================
# get_container_ip : Get the IP address of the container.
# get_elapsed_time : Get the elapsed time since the container started.
# wait_until_elapsed : Wait until the container has been running for the required time.
# ==============================================

function get_container_ip() {
  local container_name="$1"
  docker inspect ats-vault | jq -r '.[0]["NetworkSettings"]["Networks"]["ats-internal-network"]["IPAddress"]'
}

function get_elapsed_time() {
    local container_name="$1"
    # 컨테이너가 실행 중인지 확인
    local status=$(docker inspect --format='{{.State.Status}}' "$container_name" 2>/dev/null)
    if [ "$status" != "running" ]; then
        echo "Error: Container '$container_name' is not running." >&2
        return 1
    fi

    # 시작 시간 가져오기
    local started_at=$(docker inspect --format='{{.State.StartedAt}}' "$container_name")
    local started_at_epoch=$(date -d "$started_at" +%s)
    local current_time_epoch=$(date +%s)

    # 경과 시간 계산
    echo $((current_time_epoch - started_at_epoch))
}

wait_until_elapsed() {
    local container_name="$1"
    local required_seconds="$2"
    local max_retries="$3"
    local retry_interval="$required_seconds"

    echo "Checking elapsed time for container: $container_name..."

    for ((i=1; i<=max_retries; i++)); do
        local elapsed_time=$(get_elapsed_time "$container_name")
        if [ $? -ne 0 ]; then
            echo "Failed to get elapsed time for container '$container_name'. Retrying... ($i/$max_retries)"
            sleep "$retry_interval"
            continue
        fi

        if [ "$elapsed_time" -lt "$required_seconds" ]; then
            local remaining_time=$((required_seconds - elapsed_time))
            echo "Attempt $i/$max_retries: Container '$container_name' has been running for $elapsed_time seconds. Waiting for $remaining_time seconds..."
            sleep "$remaining_time"
        else
            echo "Container '$container_name' has been running for $elapsed_time seconds. Proceeding with further actions."
            return 0
        fi

        sleep "$retry_interval"
    done

    echo "Max retries reached. Container '$container_name' did not meet the required elapsed time of $required_seconds seconds."
    return 1
}