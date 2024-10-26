#!/bin/bash

(
  source common.sh

  docker compose -f 30_docker-compose.monitoring.yml down -v
)
