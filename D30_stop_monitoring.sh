#!/bin/bash

(
  source load_env.sh

  docker compose -f 30_docker-compose.monitoring.yml down -v
)
