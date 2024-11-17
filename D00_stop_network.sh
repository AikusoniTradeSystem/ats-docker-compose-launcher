#!/bin/bash

# ==============================================
# Script Name:	Stop Networks
# Description:  This script stops the network.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker compose -f 00_docker-compose.network.yml down -v
)
