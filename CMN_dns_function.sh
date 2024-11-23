#!/bin/bash

# ==============================================
# Script Name:	Set Util
# Description:	This script provides a set structure for shell scripts. (It is using a file to store the set.)
# ==============================================

source CMN_load_function.sh

CORE_FILE=${DNS_CORE_FILE_PATH:-"./dns/Corefile"}
HOST_FILE="./dns/hosts.txt"
SEP="@"

mkdir -p ./dns
touch "${HOST_FILE}"

add_host() {
  local DOMAIN_NAME="${1}"
  local TARGET_ADDRESS="${2}"
  log d "Adding ${DOMAIN_NAME} -> ${TARGET_ADDRESS} INTO ${HOST_FILE}"
  try ./CMN_set.sh --file="${HOST_FILE}" --add="${DOMAIN_NAME}${SEP}${TARGET_ADDRESS}"
}

remove_host() {
  local DOMAIN_NAME="${1}"
  log d "Removing ${DOMAIN_NAME} FROM ${HOST_FILE}"
  local found
  # \t 이전까지의 값이 ${1}과 같은 값을 찾는다
  found=$(grep -E "^${DOMAIN_NAME}${SEP}" "${HOST_FILE}")

  # 찾은 값을 제거한다.
  if [ -n "${found}" ]; then
    log d "Removing ${found} FROM ${HOST_FILE}"
    try ./CMN_set.sh --file="${HOST_FILE}" --remove="${found}"
  fi
}

clear_hosts() {
  log d "Clearing ${HOST_FILE}"
  echo "" > "${HOST_FILE}"
}

list_hosts() {
  # Show the set
  log i "Set:"
  for host in "${TMP_SET[@]}"; do
    log i "  ${host}"
  done
}

make_corefile() {
  local HOSTS
  HOSTS=$(cat "${HOST_FILE}")

  # Create Corefile
  cat <<EOF >"${CORE_FILE}"
.:53 {
    # CoreDNS plugins
    docker {
        domains docker.local
        refresh 10s
    }
    errors          # Enable error logging
    health          # Add health check endpoint
    ready           # Add readiness endpoint
    log             # Enable query logging

    # DNS forwarding to system's resolver
    forward . /etc/resolv.conf

    # Caching for 30 seconds
    cache 30

    # Hosts-based DNS entries
    hosts {
EOF

  # Append hosts entries
  while IFS= read -r line; do
    # Split line into domain and target using @ as delimiter
    local DOMAIN TARGET
    DOMAIN="${line%@*}"  # Extract everything before '@'
    TARGET="${line#*@}"  # Extract everything after '@'

    # Append the parsed domain and target to Corefile
    echo "        ${DOMAIN} ${TARGET}" >>"${CORE_FILE}"
  done <<<"${HOSTS}"

  # Close the Corefile
  cat <<EOF >>"${CORE_FILE}"
    }
}
EOF
}

dns_ip() {
  local DNS_CONTAINER_NAME="${1}"
  local IP
  IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${DNS_CONTAINER_NAME}" 2>/dev/null)
  if [ -z "$IP" ]; then
    echo "Error: Unable to retrieve IP for container ${DNS_CONTAINER_NAME}" >&2
    return 1
  fi
  echo "$IP"
}