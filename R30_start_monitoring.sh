#!/bin/bash

# ==============================================
# Script Name:  Start Monitoring Script
# Description:  This script starts the monitoring services.
# ==============================================

(
    source CMN_load_env.sh
    source CMN_load_function.sh

    # determine the architecture to build cadvisor image
    ARCH=$(uname -m)
    case "$ARCH" in
      x86_64)
        GOARCH="amd64"
        ;;
      aarch64)
        GOARCH="arm64"
        ;;
      *)
        echo -e "Unknown server architecture: $ARCH"
        exit 1
        ;;
    esac
    
    export GOARCH=$GOARCH
    
    docker compose -f 30_docker-compose.monitoring.yml pull
    docker compose -f 30_docker-compose.monitoring.yml up -d
)
