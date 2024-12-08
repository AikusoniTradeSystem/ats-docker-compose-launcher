#!/bin/bash

# ==============================================
# Script Name:  Common Functions of the ATS Docker Compose Launcher Project
# Description:	This script provides common functions.
# ==============================================

# ==============================================
# Function List
# ==============================================

function get_container_ip() {
  local container_name="$1"
  docker inspect ats-vault | jq -r '.[0]["NetworkSettings"]["Networks"]["ats-internal-network"]["IPAddress"]'
}