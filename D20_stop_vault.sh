#!/bin/bash

(
  source load_env.sh

  docker compose -f 20_docker-compose.vault.yml down -v
)
