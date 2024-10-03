#!/bin/bash

(
  export PG_DATA=./storage/pg_data

  docker compose -f 10_docker-compose.db.yml pull
  docker compose -f 10_docker-compose.db.yml build --no-cache
  docker compose -f 10_docker-compose.db.yml up -d
)
