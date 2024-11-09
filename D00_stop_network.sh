#!/bin/bash

# ==============================================
# Script Name:	Stop Networks
# Description:  This script stops the network.
# ==============================================

(
  source load_env.sh
  source load_function.sh

  try docker compose -f 00_docker-compose.network.yml down -v
)
