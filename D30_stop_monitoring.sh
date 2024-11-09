#!/bin/bash

# ==============================================
# Script Name:  Stop Monitoring
# Description:  This script stops the monitoring.
# ==============================================

(
  source load_env.sh
  source load_function.sh

  try docker compose -f 30_docker-compose.monitoring.yml down -v
)
