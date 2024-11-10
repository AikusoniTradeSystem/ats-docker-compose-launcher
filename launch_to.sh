#!/bin/bash

# ==============================================
# Script Name:    Launch To Scripts
# Description:    This script launches scripts sequentially (sorted by name) from the provided first script to the last script.
# ==============================================
# Usage:
# ./launch_to.sh --start=[start_script_prefix] --last=[last_script_prefix] [--y] [--help]
# e.g)
# if the directory has the following scripts:
# R00_0000_enable_network.sh
# R00_0010_enable_volume.sh
# R03_0000_generate_root_ca.sh
# R03_0010_generate_intermediate_ca.sh
# R03_0020_generate_vault_certs.sh
# R03_0030_generate_vault_certs.sh
# R03_BASE_generate_ca.sh
# R10_0000_enable_vault.sh
# R12_00_0000_enable_database_secrets_engine.sh
# R12_00_0010_enable_pki_secrets_engine.sh
# R12_BASE_enable_engine.sh
# R15_0000_enable_infinite_stone.sh
# R15_0010_enable_super_mario.sh
# R20_0020_su_su_su_super_nova.sh
# ]
# And, you launch the scripts from R00_00_* to R12_00_0010*, you can run the following command:
# ./launch_to.sh --start=R00 --last=R12_00_0010
# This command will execute the following scripts:
# R00_0000_enable_network.sh
# R00_0010_enable_volume.sh
# R03_0000_generate_root_ca.sh
# R03_0010_generate_intermediate_ca.sh
# R03_0020_generate_vault_certs.sh
# R03_0030_generate_vault_certs.sh
# R10_0000_enable_vault.sh
# R12_00_0000_enable_database_secrets_engine.sh
# R12_00_0010_enable_pki_secrets_engine.sh
# ==============================================

(
  AUTU_EXEC=false

  # 인자값 처리
  for arg in "$@"; do
    case $arg in
      --start=*)
        START_SCRIPT_PREFIX="${arg#*=}"
        ;;
      --last=*)
        END_SCRIPT_PREFIX="${arg#*=}"
        ;;
      --y)
        AUTO_EXEC=true
        ;;
      --help)
        echo "Usage: $0 --start=[start_script_prefix] --last=[last_script_prefix] [--y] [--help]"
        echo "options:"
        echo "  --start: The prefix of the script name to start from."
        echo "  --last: The prefix of the script name to end at."
        echo "  --y: Execute the scripts without confirmation."
        echo "  --help: Show this help message."
        exit 0
        ;;
      *)
        echo "Unknown option: $arg"
        echo "Use --help option to see the usage."
        exit 1
        ;;
    esac
  done

  source load_env.sh
  source load_function.sh

  # 실행 스크립트 목록 필터링 및 정렬
  scripts=$(ls R* | grep -v 'BASE' | sort)

  # 시작 스크립트명과 종료 스크립트명 위치 찾기
  start_index=$(echo "$scripts" | grep -n "^$START_SCRIPT_PREFIX" | head -n 1 | cut -d: -f1)
  end_index=$(echo "$scripts" | grep -n "^$END_SCRIPT_PREFIX" | tail -n 1 | cut -d: -f1)

  # 시작 스크립트명과 종료 스크립트명이 목록에 존재하는지 확인
  if [ -n "$START_SCRIPT_PREFIX" ] && [ -z "$start_index" ]; then
    log e "Error: Specified start script '$START_SCRIPT_PREFIX' does not exist in the directory."
    exit 1
  fi

  if [ -n "$END_SCRIPT_PREFIX" ] && [ -z "$end_index" ]; then
    log e "Error: Specified end script '$END_SCRIPT_PREFIX' does not exist in the directory."
    exit 1
  fi

  log d "Start index: $start_index, End index: $end_index"

  # 시작 스크립트명부터 종료 스크립트명까지의 스크립트 목록 선택
  if [ -n "$start_index" ] && [ -n "$end_index" ]; then
    scripts_to_run=$(echo "$scripts" | sed -n "${start_index},${end_index}p")
  elif [ -n "$start_index" ]; then
    scripts_to_run=$(echo "$scripts" | sed -n "${start_index},\$p")
  else
    scripts_to_run=$scripts
  fi

  # 실행 전에 확인
  if [ -z "$AUTO_EXEC" ]; then
    log i "The following scripts will be executed:"
    for script in $scripts_to_run; do
      log i "  - $script"
    done
    read -p "Do you want to proceed? (y/n): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      log e "Operation cancelled."
      exit 0
    fi
  fi

  # 선택된 스크립트들을 순차적으로 실행
  for script in $scripts_to_run; do
    if [ -x "$script" ]; then
      log i "Executing $script..."
      ./$script
      exit_on_error "Error occurred while executing $script."
    else
      log e "Error: $script is not executable. Please check the file permission."
      exit 2
    fi
  done
)