#!/bin/bash

# ==============================================
# Script Name:  Stop All
# Description:  This script stops all instances of the ats project.
# ==============================================

(
  source load_env.sh
  source load_function.sh

  for file in $(find . -name '*docker-compose*.yml' | sort -r)
  do
    try docker compose -f "$file" down -v
  done
)
