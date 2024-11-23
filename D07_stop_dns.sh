#!/bin/bash

# ==============================================
# Script Name:	Stop DNS
# Description:  This script stops the DNS server.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker compose -f 07_docker-compose.dns.yml down -v
)
