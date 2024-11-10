#!/bin/bash

# ==============================================
# Script Name:    Launch To Scripts
# Description:    This script launches scripts sequentially (sorted by name) from the provided first script to the last script.
# ==============================================
# Usage:
# ./launch_to.sh --first=[first_script_name] --last[last_script_name]
# ==============================================

(
  source load_env.sh
  source load_function.sh

  # 인자값 처리
  for arg in "$@"; do
    case $arg in
      --first=*)
        START_SCRIPT="${arg#*=}"
        ;;
      --last=*)
        END_SCRIPT="${arg#*=}"
        ;;
      *)
        log e "Unknown option: $arg"
        exit 1
        ;;
    esac
  done

  # 실행 스크립트 목록 필터링 및 정렬
  scripts=$(ls R* | grep -v 'BASE' | sort)

  # 시작 스크립트명과 종료 스크립트명 위치 찾기
  start_index=$(echo "$scripts" | grep -n "^$START_SCRIPT$" | cut -d: -f1)
  end_index=$(echo "$scripts" | grep -n "^$END_SCRIPT$" | cut -d: -f1)

  # 시작 스크립트명과 종료 스크립트명이 목록에 존재하는지 확인
  if [ -n "$START_SCRIPT" ] && [ -z "$start_index" ]; then
    log e "Error: Specified start script '$START_SCRIPT' does not exist in the directory."
    exit 1
  fi

  if [ -n "$END_SCRIPT" ] && [ -z "$end_index" ]; then
    log e "Error: Specified end script '$END_SCRIPT' does not exist in the directory."
    exit 1
  fi

  # 시작 스크립트명부터 종료 스크립트명까지의 스크립트 목록 선택
  if [ -n "$START_SCRIPT" ] && [ -n "$END_SCRIPT" ]; then
    scripts_to_run=$(echo "$scripts" | sed -n "${start_index},${end_index}p")
  elif [ -n "$START_SCRIPT" ]; then
    scripts_to_run=$(echo "$scripts" | sed -n "${start_index},\$p")
  else
    scripts_to_run=$scripts
  fi

  # 선택된 스크립트들을 순차적으로 실행
  for script in $scripts_to_run; do
    if [ -x "$script" ]; then
      log i "Executing $script..."
      ./$script
      if [ $? -ne 0 ]; then
        log e "Error: $script failed to execute."
        exit 1
      fi
    else
      log e "Error: $script is not executable. Please check the file permission."
      exit 2
    fi
  done
)