#!/bin/bash
(
  docker compose -f 20_docker-compose.vault.yml down -v
)
