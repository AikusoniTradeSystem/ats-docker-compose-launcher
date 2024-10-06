#!/bin/bash
(
  docker compose -f 10_docker-compose.db.yml down -v
)
