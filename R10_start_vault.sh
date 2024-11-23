#!/bin/bash

# ==============================================
# Script Name:	Start Vault
# Description:	This script starts the Vault server container.
# ==============================================

(
  DOCKER_COMPOSE_FILE_NAME="10_docker-compose.vault.yml"

  source CMN_load_env.sh
  source CMN_load_function.sh
  source CMN_dns_function.sh

  try add_host "vault.ats.internal" "ats-vault"
  try make_corefile

  CUSTOM_DNS_IP=$(dns_ip "${DNS_CONTAINER_NAME}")
  export CUSTOM_DNS_IP

  log d "CUSTOM_DNS_IP: ${CUSTOM_DNS_IP}"

  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" pull
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" build --no-cache
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" up -d
)