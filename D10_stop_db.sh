#!/bin/bash

(
  source load_env.sh

  docker compose -f 10_docker-compose.db.yml down -v
)
