#!/bin/bash
(
  source load_env.sh

  docker compose -f 01_docker-compose.volume.yml down -v
)
