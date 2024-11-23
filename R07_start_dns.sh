#!/bin/bash

# ==============================================
# Script Name:	Start DNS
# Description:	This script starts the DNS server for docker network.
# ==============================================

(
  DOCKER_COMPOSE_FILE_NAME="07_docker-compose.dns.yml"

  source CMN_load_env.sh
  source CMN_load_function.sh
  source CMN_dns_function.sh

  try clear_hosts
  try add_host "first-domain.ats.internal" "localhost"
  try make_corefile

  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" pull
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" build --no-cache
  try docker compose -f "${DOCKER_COMPOSE_FILE_NAME}" up -d
)
