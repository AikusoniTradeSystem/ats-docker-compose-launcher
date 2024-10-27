#!/bin/bash

(
  source load_env.sh

  docker compose -f 40_docker-compose.develop.yml down -v
)
