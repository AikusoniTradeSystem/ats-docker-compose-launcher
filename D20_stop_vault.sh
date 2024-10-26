#!/bin/bash

(
  source common.sh

  docker compose -f 20_docker-compose.vault.yml down -v
)
