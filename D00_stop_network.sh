#!/bin/bash
(
  source load_env.sh

  docker compose -f 00_docker-compose.network.yml down -v
)
