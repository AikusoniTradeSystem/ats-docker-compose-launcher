#!/bin/bash

# ==============================================
# Script Name:  Stop Monitoring
# Description:  This script stops the monitoring.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker compose -f 30_docker-compose.monitoring.yml down -v
)
