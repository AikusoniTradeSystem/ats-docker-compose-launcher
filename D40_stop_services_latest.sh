#!/bin/bash

(
  source load_env.sh

  docker compose -f 40_docker-compose.latest.yml down -v
)
